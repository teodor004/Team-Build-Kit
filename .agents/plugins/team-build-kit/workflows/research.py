# Stage A Research Fan-Out (Antigravity Dynamic Workflow `run_workflow`)
# Usage: run_workflow(ScriptPath=".agents/plugins/team-build-kit/workflows/research.py", Args={"slug": "...", "objective": "...", "date": "YYYY-MM-DD"})

roles = (args or {}).get("roles") or [
    "solution-architect",
    "ux-designer",
    "security-architect",
    "backend-developer",
    "frontend-developer",
]
slug = (args or {}).get("slug", "run")
objective = (args or {}).get("objective", "")
date_str = (args or {}).get("date", "")

phase("Research & Design")

brief_schema = {
    "type": "object",
    "required": [
        "contract",
        "role",
        "standards",
        "recommendation",
        "acceptance_criteria",
        "unknowns",
    ],
    "properties": {
        "contract": {"type": "string"},
        "role": {"type": "string"},
        "standards": {
            "type": "array",
            "items": {
                "type": "object",
                "required": ["url", "accessed"],
                "properties": {
                    "url": {"type": "string"},
                    "accessed": {"type": "string"},
                    "title": {"type": "string"},
                },
            },
        },
        "recommendation": {"type": "array", "items": {"type": "object"}},
        "acceptance_criteria": {"type": "array", "items": {"type": "object"}},
        "unknowns": {"type": "array", "items": {"type": "string"}},
    },
}

briefs = await parallel(
    roles,
    lambda role: agent(
        prompt=(
            f'You are the {role} for team run "{slug}". Objective (verbatim): {objective}. Today is {date_str}. '
            f"Research official standards/docs (max 6 web searches, 10 fetches; if no search tool exists, fetch primary-source URLs directly). "
            f'Every claim needs a URL and access date; unknowns must be "UNKNOWN". '
            f'Do not edit files. Return contract "role-brief/v1".'
        ),
        schema=brief_schema,
        role=role,
        type_name=role,
        workspace="inherit",
        model="pro" if role == "solution-architect" else "flash",
    ),
)

valid_briefs = [b for b in briefs if b]
log(f"briefs returned: {len(valid_briefs)}/{len(roles)}")
valid_briefs
