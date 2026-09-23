"""Roastery admin CLI — the shared, non-team-owned tooling for this workshop.

This does NOT know about any team's tables or event shapes — there aren't any
predefined ones. It only does three things every team needs regardless of what
they build: print the shared catalogs (real product/lot/roastable data, not
sandbox filler), publish an arbitrary event onto the shared bus for testing,
and nothing else. `just logs` (a thin `aws logs tail` wrapper, not this file)
is how you watch what happens after you publish.

Run via `just <recipe>` from this directory — see `justfile`.
"""
from __future__ import annotations

import argparse
import json
import sys
import uuid
from datetime import datetime, timezone
from pathlib import Path

import boto3

CATALOG_DIR = Path(__file__).resolve().parent.parent
DEFAULT_BUS_NAME = "roastery-bus"


def load_catalog() -> list[dict]:
    return json.loads((CATALOG_DIR / "skus.json").read_text())["skus"]


def load_green_lots() -> list[dict]:
    return json.loads((CATALOG_DIR / "green_lots.json").read_text())["greenLots"]


def load_roastables() -> list[dict]:
    return json.loads((CATALOG_DIR / "roastables.json").read_text())["roastables"]


def _now() -> str:
    return datetime.now(timezone.utc).isoformat()


def cmd_list_skus(_args: argparse.Namespace) -> None:
    for sku in load_catalog():
        print(json.dumps(sku))


def cmd_list_green_lots(_args: argparse.Namespace) -> None:
    for lot in load_green_lots():
        print(json.dumps(lot))


def cmd_list_roastables(_args: argparse.Namespace) -> None:
    for roastable in load_roastables():
        print(json.dumps(roastable))


def cmd_publish(args: argparse.Namespace) -> None:
    """Publish one arbitrary event onto the shared bus.

    This is a generic test tool, not a stand-in for any team's front door —
    it does not know or assume any event shape. Useful for proving your
    EventBridge rule actually fires before another team's code exists to
    trigger it for real.
    """
    try:
        detail = json.loads(args.detail) if args.detail else {}
    except json.JSONDecodeError as e:
        print(f"error: --detail must be valid JSON: {e}", file=sys.stderr)
        raise SystemExit(1)

    if isinstance(detail, dict) and "eventId" not in detail:
        detail = {"eventId": str(uuid.uuid4()), "occurredAt": _now(), **detail}

    events = boto3.client("events")
    resp = events.put_events(
        Entries=[
            {
                "Source": args.source,
                "DetailType": args.detail_type,
                "Detail": json.dumps(detail),
                "EventBusName": args.bus_name,
            }
        ]
    )
    if resp.get("FailedEntryCount"):
        print(json.dumps(resp["Entries"]), file=sys.stderr)
        raise SystemExit(1)
    print(f"published {args.detail_type} to {args.bus_name}: {json.dumps(detail)}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--bus-name", default=DEFAULT_BUS_NAME, help=f"default: {DEFAULT_BUS_NAME}"
    )
    sub = parser.add_subparsers(dest="command", required=True)

    sub.add_parser("list-skus", help="print the shared SKU catalog").set_defaults(
        func=cmd_list_skus
    )
    sub.add_parser(
        "list-green-lots", help="print the shared green-lot catalog"
    ).set_defaults(func=cmd_list_green_lots)
    sub.add_parser(
        "list-roastables", help="print the shared roastable catalog"
    ).set_defaults(func=cmd_list_roastables)

    p_publish = sub.add_parser(
        "publish", help="publish one arbitrary event onto the shared bus"
    )
    p_publish.add_argument(
        "--detail-type", required=True, help='e.g. "SayHelloEvent"'
    )
    p_publish.add_argument(
        "--detail", default="{}", help="JSON object body, default: {}"
    )
    p_publish.add_argument(
        "--source", default="roastery.cli", help='default: "roastery.cli"'
    )
    p_publish.set_defaults(func=cmd_publish)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
