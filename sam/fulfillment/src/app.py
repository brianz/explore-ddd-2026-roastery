"""Fulfillment — starter Lambda.

TODO, as a team: replace this with real logic once you've decided what
this context owns and how it should react to events on the shared bus.
This handler only proves the wiring works: it's invoked by the
placeholder "SayHelloEvent" rule in template.yaml, prints a hello-world
line plus whatever event it received, and returns.

It does not touch HelloTable — that resource is a placeholder for
whatever DynamoDB schema you actually design. A trivial example of using
it, once you have a reason to:

    import boto3, os
    table = boto3.resource("dynamodb").Table(os.environ["TABLE_NAME"])
    table.put_item(Item={"id": "example", "seenAt": ...})

Delete HelloTable from template.yaml if you don't end up needing it.
"""
import json
import os

CONTEXT_NAME = os.environ.get("CONTEXT_NAME", "fulfillment")


def handler(event, context):
    detail_type = event.get("detail-type", "<unknown>")
    detail = event.get("detail", {})
    print(f"[{CONTEXT_NAME}] hello, world! heard {detail_type}: {json.dumps(detail)}")
