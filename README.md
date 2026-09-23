# explore-ddd-2026-roastery

A 2-hour hands-on workshop. Five teams, five bounded contexts of a coffee
roastery, one shared AWS account, one shared EventBridge bus. You integrate
through events you and the other teams design together — nothing is handed
to you predefined.

**Where to start**

| If you want to… | Read |
|---|---|
| Get your environment running | [docs/ATTENDEE-QUICKSTART.md](./docs/ATTENDEE-QUICKSTART.md) |
| Understand the shared rules of the room | [docs/student/GROUND-RULES.md](./docs/student/GROUND-RULES.md) |
| Find out what your team owns | `docs/student/<your-context>.md` |
| Run and deploy your context | [sam/README.md](./sam/README.md) |

**Prerequisites:** Docker Desktop, VS Code with the Dev Containers extension. AWS
credentials are provided by your facilitator (see `docs/ATTENDEE-QUICKSTART.md`).

There is no local or in-memory mode; every run is against real, deployed AWS
resources on one shared account.
