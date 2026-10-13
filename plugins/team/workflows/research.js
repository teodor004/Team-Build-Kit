export const meta = {
  name: 'research',
  description: 'Team Stage A only: parallel role research briefs (no mid-run input; run /team:build --resume for consolidation)',
  phases: [
    { title: 'Research & Design', detail: 'one role-brief/v1 per role, in parallel' },
  ],
}

// args: { slug: string, objective: string, date: "YYYY-MM-DD", roles?: string[] }
const roles = (args && args.roles) || ['solution-architect', 'ux-designer', 'security-architect', 'backend-developer', 'frontend-developer']

phase('Research & Design')
const briefSchema = {
  type: 'object',
  required: ['contract', 'role', 'standards', 'recommendation', 'acceptance_criteria', 'unknowns'],
  properties: {
    contract: { type: 'string' }, role: { type: 'string' },
    standards: { type: 'array', items: { type: 'object', required: ['url', 'accessed'], properties: { url: { type: 'string' }, accessed: { type: 'string' }, title: { type: 'string' } } } },
    recommendation: { type: 'array', items: { type: 'object' } },
    acceptance_criteria: { type: 'array', items: { type: 'object' } },
    unknowns: { type: 'array', items: { type: 'string' } },
  },
}

const briefs = await pipeline(roles, role =>
  agent(
    `You are the ${role} for team run "${args.slug}". Objective (verbatim): ${args.objective}. Today is ${args.date}. ` +
    `Research official standards/docs (max 6 web searches, 10 fetches; if no search tool exists, fetch primary-source URLs directly). ` +
    `Every claim needs a URL and access date; unknowns must be "UNKNOWN". ` +
    `Do not edit files. Return contract "role-brief/v1".`,
    { label: role, phase: 'Research & Design', schema: briefSchema, agentType: `team:${role}` },
  ),
)
log(`briefs returned: ${briefs.filter(Boolean).length}/${roles.length}`)
return briefs.filter(Boolean)
