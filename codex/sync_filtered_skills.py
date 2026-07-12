#!/usr/bin/env python3
"""
Synchronize global MATLAB Agentic Toolkit skills with installed MATLAB products.

This script is intentionally kept outside the upstream toolkit repository. Run it
after the official setup script, after `git pull`, or after installing/removing
MATLAB toolboxes. It reads each skill manifest with PyYAML, compares
`required-products` against the products reported by MATLAB `ver`, and then keeps
only compatible skill links in ~/.agents/skills.
"""

from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

import yaml


DEFAULT_TOOLKIT_ROOT = Path(r"C:\Users\lapis\Downloads\matlab-agentic-toolkit")
DEFAULT_MATLAB_ROOT = Path(r"C:\Program Files\MATLAB\R2026a")
DEFAULT_SKILLS_ROOT = Path.home() / ".agents" / "skills"


@dataclass(frozen=True)
class SkillDecision:
    """The result of evaluating one skill manifest."""

    name: str
    skill_dir: Path
    manifest: Path
    required_products: tuple[str, ...]
    missing_products: tuple[str, ...]

    @property
    def should_link(self) -> bool:
        return not self.missing_products


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Filter MATLAB Agentic Toolkit global skills to products installed "
            "in the selected MATLAB installation."
        )
    )
    parser.add_argument(
        "--toolkit-root",
        type=Path,
        default=DEFAULT_TOOLKIT_ROOT,
        help=f"Toolkit repository root. Default: {DEFAULT_TOOLKIT_ROOT}",
    )
    parser.add_argument(
        "--matlab-root",
        type=Path,
        default=DEFAULT_MATLAB_ROOT,
        help=f"MATLAB installation root. Default: {DEFAULT_MATLAB_ROOT}",
    )
    parser.add_argument(
        "--skills-root",
        type=Path,
        default=DEFAULT_SKILLS_ROOT,
        help=f"Global skills directory. Default: {DEFAULT_SKILLS_ROOT}",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print planned changes without modifying ~/.agents/skills.",
    )
    parser.add_argument(
        "--keep-extra",
        action="store_true",
        help=(
            "Do not remove extra links/directories in skills-root that are not "
            "published by this toolkit."
        ),
    )
    return parser.parse_args()


def normalize_product_name(name: str) -> str:
    """Normalize product names for exact-but-case-insensitive comparison."""

    return " ".join(name.strip().casefold().split())


def matlab_executable(matlab_root: Path) -> Path:
    """Return the platform-specific MATLAB executable path."""

    if os.name == "nt":
        return matlab_root / "bin" / "matlab.exe"
    return matlab_root / "bin" / "matlab"


def query_installed_products(matlab_root: Path) -> set[str]:
    """Ask MATLAB for installed product display names using `ver`.

    The skill manifests use product display names such as "Antenna Toolbox".
    MATLAB `ver` reports the same display names for installed products, which is
    the comparison source used here.
    """

    exe = matlab_executable(matlab_root)
    if not exe.exists():
        raise FileNotFoundError(f"MATLAB executable not found: {exe}")

    matlab_code = "v=ver; for k=1:numel(v), fprintf('%s\\n', v(k).Name); end"
    result = subprocess.run(
        [str(exe), "-batch", matlab_code],
        check=False,
        text=True,
        encoding="utf-8",
        errors="replace",
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if result.returncode != 0:
        raise RuntimeError(
            "Failed to query installed MATLAB products.\n"
            f"Command: {exe} -batch {matlab_code!r}\n"
            f"stderr:\n{result.stderr.strip()}"
        )

    return {
        normalize_product_name(line)
        for line in result.stdout.splitlines()
        if line.strip()
    }


def discover_manifests(toolkit_root: Path) -> list[Path]:
    """Find published skill manifests under skills-catalog/<domain>/<skill>."""

    catalog = toolkit_root / "skills-catalog"
    if not catalog.exists():
        raise FileNotFoundError(f"skills-catalog not found: {catalog}")

    manifests: list[Path] = []
    for manifest in catalog.rglob("manifest.yaml"):
        relative = manifest.relative_to(catalog)
        # Published skills are exactly two levels below skills-catalog:
        # skills-catalog/<domain>/<skill>/manifest.yaml
        if len(relative.parts) == 3 and relative.parts[-1] == "manifest.yaml":
            manifests.append(manifest)
    return sorted(manifests, key=lambda path: str(path).casefold())


def read_required_products(manifest: Path) -> tuple[str, ...]:
    """Read required-products from a manifest using real YAML parsing.

    Missing required-products means "no declared product dependency". A scalar
    is accepted defensively and treated as one product. Invalid item types fail
    loudly because silently linking the wrong skill is worse than stopping.
    """

    with manifest.open("r", encoding="utf-8") as handle:
        data = yaml.safe_load(handle) or {}

    value = data.get("required-products", [])
    if value is None:
        return ()
    if isinstance(value, str):
        return (value,)
    if not isinstance(value, list):
        raise TypeError(
            f"{manifest}: required-products must be a list, string, null, or omitted"
        )

    products: list[str] = []
    for item in value:
        if not isinstance(item, str):
            raise TypeError(f"{manifest}: required-products item is not a string: {item!r}")
        if item.strip():
            products.append(item.strip())
    return tuple(products)


def evaluate_skills(toolkit_root: Path, installed_products: set[str]) -> list[SkillDecision]:
    """Build link/skip decisions for every published skill manifest."""

    decisions: list[SkillDecision] = []
    for manifest in discover_manifests(toolkit_root):
        skill_dir = manifest.parent
        required = read_required_products(manifest)
        missing = tuple(
            product
            for product in required
            if normalize_product_name(product) not in installed_products
        )
        decisions.append(
            SkillDecision(
                name=skill_dir.name,
                skill_dir=skill_dir,
                manifest=manifest,
                required_products=required,
                missing_products=missing,
            )
        )
    return decisions


def remove_existing(path: Path, dry_run: bool) -> None:
    """Remove an existing skill link/directory before recreating or skipping it."""

    if not path.exists() and not path.is_symlink():
        return
    if dry_run:
        print(f"Would remove {path}")
        return

    if path.is_symlink() or path.is_file():
        path.unlink()
    elif hasattr(path, "is_junction") and path.is_junction():
        # Windows directory junctions should be removed with rmdir; rmtree
        # refuses them and following them would be the wrong behavior anyway.
        path.rmdir()
    else:
        shutil.rmtree(path)


def create_skill_link(link_path: Path, target: Path, dry_run: bool) -> None:
    """Create a symlink when possible, falling back to a Windows junction."""

    if dry_run:
        print(f"Would link {link_path} -> {target}")
        return

    try:
        link_path.symlink_to(target, target_is_directory=True)
    except OSError:
        if os.name != "nt":
            raise
        subprocess.run(
            ["cmd", "/c", "mklink", "/J", str(link_path), str(target)],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )


def cleanup_extra_toolkit_links(
    skills_root: Path,
    decisions: Iterable[SkillDecision],
    toolkit_root: Path,
    dry_run: bool,
    keep_extra: bool,
) -> int:
    """Remove stale toolkit skill links that no longer have a manifest.

    This only removes entries whose resolved target is inside the selected toolkit
    root. Unrelated user skills under ~/.agents/skills are left alone.
    """

    if keep_extra or not skills_root.exists():
        return 0

    valid_names = {decision.name for decision in decisions}
    removed = 0
    toolkit_root_resolved = toolkit_root.resolve()

    for entry in skills_root.iterdir():
        if entry.name in valid_names:
            continue
        try:
            target = entry.resolve(strict=False)
        except OSError:
            continue
        if not str(target).casefold().startswith(str(toolkit_root_resolved).casefold()):
            continue
        remove_existing(entry, dry_run)
        print(f"Removed stale toolkit skill {entry}")
        removed += 1
    return removed


def sync_skills(decisions: list[SkillDecision], skills_root: Path, dry_run: bool) -> tuple[int, int, int]:
    """Apply decisions to ~/.agents/skills and return linked/skipped/removed counts."""

    if not dry_run:
        skills_root.mkdir(parents=True, exist_ok=True)

    linked = 0
    skipped = 0
    removed = 0

    for decision in decisions:
        link_path = skills_root / decision.name
        if decision.should_link:
            remove_existing(link_path, dry_run)
            create_skill_link(link_path, decision.skill_dir, dry_run)
            if not dry_run:
                print(f"Linked {link_path} -> {decision.skill_dir}")
            linked += 1
            continue

        if link_path.exists() or link_path.is_symlink():
            remove_existing(link_path, dry_run)
            removed += 1
            action = "Would remove" if dry_run else "Removed"
            print(
                f"{action} {link_path} "
                f"(missing: {', '.join(decision.missing_products)})"
            )
        else:
            print(
                f"Skipped {decision.name} "
                f"(missing: {', '.join(decision.missing_products)})"
            )
        skipped += 1

    return linked, skipped, removed


def main() -> int:
    args = parse_args()
    toolkit_root = args.toolkit_root.resolve()
    matlab_root = args.matlab_root.resolve()
    skills_root = args.skills_root.expanduser().resolve()

    print(f"Toolkit root: {toolkit_root}")
    print(f"MATLAB root:  {matlab_root}")
    print(f"Skills root:  {skills_root}")
    if args.dry_run:
        print("Mode:         dry-run")

    installed_products = query_installed_products(matlab_root)
    decisions = evaluate_skills(toolkit_root, installed_products)
    linked, skipped, removed = sync_skills(decisions, skills_root, args.dry_run)
    stale_removed = cleanup_extra_toolkit_links(
        skills_root=skills_root,
        decisions=decisions,
        toolkit_root=toolkit_root,
        dry_run=args.dry_run,
        keep_extra=args.keep_extra,
    )

    print("")
    print(f"Published skills: {len(decisions)}")
    print(f"Linked skills:    {linked}")
    print(f"Skipped skills:   {skipped}")
    print(f"Removed skipped:  {removed}")
    print(f"Removed stale:    {stale_removed}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"error: {exc}", file=sys.stderr)
        raise SystemExit(1)