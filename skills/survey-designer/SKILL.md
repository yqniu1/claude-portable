---
name: survey-designer
description: Design research-grade surveys for K12 district and school evaluation contexts. Use this skill whenever a researcher asks to create, draft, design, improve, or validate a survey for families/parents or staff/teachers in a school or district setting. Always use this skill when the user mentions parent surveys, family surveys, teacher surveys, staff surveys, K12 evaluation, school climate surveys, program feedback forms, construct validity, survey reliability, or response bias — even if they don't use the word "survey." Produces a complete plain-text survey with Likert-scale items and a design rationale covering construct alignment, validity evidence, bias mitigation, and equity considerations.
---

# Survey Designer — K12 District & School Evaluation

## Audience
Researchers conducting district/school evaluations using family/parent or staff/teacher surveys.

---

## Step 1 — Establish Research Purpose Before Writing Items

The research question drives everything. Ask the researcher:
- What decision or claim will this data support?
- Is this formative (improve a program) or summative (judge outcomes)?
- Will results be reported internally, published, or used for grant accountability?
- Is this a new instrument or adaptation of an existing validated scale?

**If an existing validated instrument exists for the construct** (e.g., Hoover-Dempsey & Sandler for parent involvement; Epstein/PTA scales for family-school partnership), recommend using or adapting it. Creating a new instrument requires substantially more validity work — warn the researcher of this tradeoff upfront.

---

## Step 2 — Define and Operationalize Constructs

A **construct** is an abstract concept being measured (e.g., "family engagement," "sense of belonging").

For each construct:
1. Provide a precise written definition
2. Identify its sub-dimensions (most constructs are multi-dimensional — do not treat them as one)
3. Map each sub-dimension to 2–4 items
4. State what a high vs. low score means in plain terms

**Example decomposition:**
> "Family-school communication" →
> - Clarity of school communications
> - Frequency of two-way communication
> - Accessibility of communication channels

Each sub-dimension may warrant its own reliability analysis later. Do not collapse them into a single scale without justification.

---

## Step 3 — Build the Item Pool with Research Rigor

### Item Writing Rules (Non-Negotiable)
| Rule | Why It Matters |
|---|---|
| One construct per item | Double-barreled items produce uninterpretable data |
| Avoid negations ("I do not feel...") | Increases cognitive load; contributes to misresponse |
| Avoid leading language | Inflates scores via demand characteristics |
| Write from respondent's direct experience | "My child's teacher..." not "Teachers at this school..." |
| Balance positively and negatively keyed items | Detects and mitigates acquiescence bias |
| Vary syntax across items | Reduces satisficing (auto-piloting through a survey) |

### Acquiescence Bias
**Definition:** Respondents agree with items regardless of content — a "yes bias."

**Mitigation:**
- Include reversed items (e.g., if Item 3 says "I feel welcome," Item 7 might say "I sometimes feel unwelcome sharing my concerns")
- Flag reversed items in the rationale with [R] notation
- At analysis, reverse-code [R] items before computing scale scores
- Aim for ~25–30% reversed items per scale

### Social Desirability Bias
**Definition:** Respondents answer to appear favorable rather than honestly. Especially prominent in family surveys where parents want to seem engaged or supportive.

**Mitigation:**
- Anonymous administration is the strongest mitigation — state this explicitly in the survey intro
- Use neutral, non-judgmental language (avoid "How often do you help your child with homework?" → use "In a typical week, how often does your family have time to review school materials?")
- Emphasize that all responses are equally useful ("There are no right or wrong answers")
- Behavioral anchors reduce abstraction ("In the last 30 days..." rather than "Generally...")

---

## Step 4 — Apply Audience-Specific Language

### Family/Parent Surveys
- **Target reading level:** 5th–6th grade (Flesch-Kincaid)
- Sentences ≤15 words preferred
- Spell out all acronyms on first use (IEP = Individualized Education Program)
- Use "your child" not "the student"
- Avoid education jargon: "instructional supports," "formative assessment," "MTSS"
- Use specific, concrete timeframes: "in the last month" not "usually"
- Use inclusive family language: "your family" or "you or another adult in your home," not just "parents"

### Staff/Teacher Surveys
- Professional but plain language
- Education terms acceptable if standard in the field
- Frame from respondent's direct professional experience
- Avoid administrative or bureaucratic framing ("To what extent does leadership ensure...") — ask the teacher what they observe directly

---

## Step 5 — Validity Framework

**Validity** = does the survey measure what it claims to measure?

Validity is not a single test — it is an *argument* assembled from multiple evidence sources. Anticipate scrutiny on each:

| Validity Type | Definition | How to Establish |
|---|---|---|
| **Content validity** | Items fully represent the construct domain | Consult literature; have subject matter experts rate item-construct alignment |
| **Face validity** | Items appear relevant to respondents | Cognitive interviews with 5–8 target respondents |
| **Construct validity** | Items relate to each other and to related/unrelated constructs as expected | Factor analysis after data collection; convergent and discriminant validity checks |
| **Criterion validity** | Scores predict or correlate with a known external measure | Compare to existing validated scales measuring same construct |

In the rationale, explicitly state which validity evidence types are addressed by the design and which require post-collection analysis.

**Common research community challenge:** "You haven't established construct validity."
**Response built into design:** The rationale documents the theoretical basis (content validity); pilot testing procedures establish face validity; the researcher is instructed to conduct factor analysis post-collection.

---

## Step 6 — Reliability Planning

**Reliability** = consistency of measurement. A survey can be reliable without being valid, but cannot be valid without being reliable.

### Internal Consistency (Cronbach's Alpha)
- **Target:** α ≥ 0.70 per subscale (Nunnally, 1978 standard in educational research)
- **Caution:** Alpha above 0.95 may indicate item redundancy — do not over-engineer
- **Important:** Alpha is calculated *per construct subscale*, not for the whole survey
- **Critical caveat:** Cronbach's alpha assumes unidimensionality within a subscale. If a subscale is theoretically multi-dimensional, report alpha with this caveat or use McDonald's Omega instead

### Test-Retest Reliability
- For high-stakes or longitudinal instruments, recommend administering to a small pilot group twice, 2–4 weeks apart
- Correlation ≥ 0.70 indicates acceptable stability

### In the Rationale, Always State:
- Which reliability statistic is planned
- At what unit (subscale vs. full instrument)
- What threshold is considered acceptable and why

---

## Step 7 — Likert Scale Design

### Scale Selection

| Scale | Use When | Notes |
|---|---|---|
| **4-point** (Strongly Agree → Strongly Disagree) | Family surveys; attitude/perception items | Recommended default — forces directional response, reduces acquiescence midpoint |
| **5-point** (adds Neutral) | Staff surveys where "no opinion" is genuinely valid | Use sparingly; midpoint invites satisficing |
| **4-point Frequency** (Always/Often/Sometimes/Never) | Behavioral items | Pair with a specific timeframe |

### Labeling Rules
- Label all points, not just endpoints — unlabeled midpoints produce uninterpretable data
- Use consistent direction throughout (high = positive, low = negative, always)
- Print scale labels once per section, not after every item

### Response Option Considerations
- Avoid offering "N/A" unless genuinely applicable — it introduces missing data patterns that complicate analysis
- If N/A is needed, place it visually apart from the scale (not on the continuum)

---

## Step 8 — Equity & Accessibility (Mandatory)

Every survey output must include an **Equity Notes** section addressing:

1. **Language access:** Identify likely non-English speaking populations. Recommend professional translation (not machine translation) for surveys with >15% non-English-speaking respondents. Note that back-translation validation is the research standard.
2. **Low-literacy accommodations:** Consider oral administration with a neutral reader; offer simplified companion version at 3rd–4th grade level for family surveys
3. **Cultural responsiveness:** Audit for Western-centric assumptions about parent involvement, family structure, and school-home relationships. Involve community liaisons in cognitive interview process.
4. **Digital access:** If distributed digitally, ensure screen reader compatibility. Offer paper alternative.
5. **Power dynamics:** Families may perceive surveys as connected to services or support for their child. State clearly that responses do not affect school services.
6. **Disability access:** Large print, alternative formats available on request

---

## Step 9 — Pilot Testing Protocol

Before full distribution, the researcher should:

1. **Cognitive interviews** (5–8 participants from target population)
   - Ask respondents to think aloud as they complete each item
   - Probe: "What did you think this question was asking?" "How did you choose your answer?"
   - Identify: confusing items, double interpretations, culturally misaligned wording

2. **Timing check:** Survey should take ≤10 minutes for families; ≤15 for staff. Longer surveys risk fatigue-induced response bias.

3. **Item revision:** Revise or drop items that produce inconsistent interpretation in cognitive interviews

Include a pilot testing recommendation in every rationale.

---

## Step 10 — Design Rationale Output Structure

Produce a rationale with these labeled sections:

```
SURVEY DESIGN RATIONALE

1. Research Purpose & Use of Findings
2. Construct Map (table: construct → sub-dimensions → item numbers)
3. Item-Level Notes (flag reversed items, note any sensitive items)
4. Validity Evidence Plan (which types addressed at design stage vs. post-collection)
5. Reliability Plan (which statistic, at what unit, target threshold)
6. Bias Mitigation Strategies Applied
7. Reading Level & Language Decisions
8. Equity & Accessibility Notes
9. Pilot Testing Recommendation
10. Limitations (what this survey cannot tell you)
```

---

## Survey Structure Template

```
[DISTRICT/SCHOOL NAME]
[Survey Title]
[Date]

---
INTRODUCTION (required, 3–4 sentences):
Who is asking and why | How data will be used | Anonymity assurance | "No right or wrong answers"
---

[Section 1: Section Title — Construct Name]
[Scale printed once here: Strongly Agree | Agree | Disagree | Strongly Disagree]

1. [Item]
2. [Item]
3. [Item — reversed, flagged internally as [R]]

[Section 2: Section Title — Construct Name]
...

---
Optional: "Is there anything else you would like us to know?"

Thank you. Your responses help us improve our school/program.
```

---

## Pre-Delivery Quality Checklist

Before outputting the final survey, verify:

- [ ] Each item tests one and only one idea
- [ ] No double-barreled, leading, or negated items
- [ ] 25–30% of items per subscale are reversed and flagged [R]
- [ ] Family survey ≤ 6th grade reading level
- [ ] Scale is consistent, labeled, and printed per section
- [ ] Intro includes anonymity assurance and "no right or wrong answers"
- [ ] Construct map exists (every item ties to a named construct)
- [ ] Equity notes section is present and specific
- [ ] Validity and reliability plans are stated in rationale
- [ ] Pilot testing is recommended
- [ ] Limitations section is included

---

## Research Community Challenges — Preemptive Responses

Build these defenses into every rationale:

| Challenge | Response Built Into Design |
|---|---|
| "No evidence of construct validity" | Content validity documented via construct map; face validity via cognitive interview recommendation; construct validity analysis (factor analysis) specified as post-collection step |
| "Alpha is too low / incorrectly calculated" | Rationale specifies alpha per subscale, states unidimensionality assumption, recommends Omega as alternative if multi-dimensional subscales |
| "Social desirability inflates family responses" | Anonymity stated in intro; neutral behavioral anchors used; equity notes address power dynamics |
| "Items are double-barreled / leading" | Item writing checklist applied; documented in rationale |
| "Reading level not appropriate" | Audience-specific language rules applied; Flesch-Kincaid target stated; pilot testing recommended |
| "No pilot testing" | Cognitive interview protocol recommended in every rationale |
| "Sample is not representative" | Noted in limitations; oversampling underrepresented families recommended; response rate flagged as validity threat |

---

## Common Mistakes to Avoid

| Mistake | Fix |
|---|---|
| Computing alpha across entire survey | Compute per subscale only |
| Treating "school climate" as one construct | Decompose: safety, belonging, communication, trust |
| All items positively keyed | Add 25–30% reversed items per subscale |
| No anonymity statement | Always include — it is a bias mitigation tool |
| 5-point scale for family surveys | Default to 4-point |
| Skipping pilot testing | Always recommend cognitive interviews |
| Reporting alpha without noting its assumptions | State unidimensionality assumption; offer Omega as alternative |
| Ignoring non-English speaking families | Flag in every equity notes section |