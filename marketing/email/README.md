# Email loop

Three workflows that look after a person's mailbox and their outreach, run as that person, with every outgoing email checked by a judge and sent only after the person approves it. The state of each thread and each outreach target lives on a page of a Nuclear Notes workspace the person connects.

## Workflows

| Workflow | What it does | Default schedule |
| --- | --- | --- |
| `email-inbox-triage` | Reconciles the pages waiting on an approval; lists the inbox's threads of the last 7 days (at most 50), drops those already labelled `zaru/triaged` and takes the oldest 10; sorts each (`mail-triage-agent`, checked by `mail-triage-judge`); labels it `zaru/triaged` and `zaru/<category>` and flags it when it needs a reply, then, in a step of its own, keeps its page; writes a reply for each that needs one (`mail-reply-drafter`, checked by `email-draft-judge`) and sends it with `mail.reply`, which waits for the person's approval. With `draft_only` true it saves each reply in the Drafts folder instead, and sends nothing. | Every 30 minutes, UTC, with up to 300 seconds of random delay: `{cron: "*/30 * * * *", timezone: "UTC", jitter_seconds: 300}` |
| `email-outreach` | Reconciles, then takes up to 10 target pages in state `queued`, writes a first email to each (`outreach-drafter`, checked by `email-draft-judge`) and sends it with `mail.send`, which waits for the person's approval; the target moves to `pitch_pending_approval`. | Weekdays at 15:00 UTC, with up to 1,800 seconds of random delay: `{cron: "0 15 * * 1-5", timezone: "UTC", jitter_seconds: 1800}` |
| `email-followup` | Reconciles, then takes each target in `sent_1` or `sent_2` whose last email is at least 4 days old with no answer since, writes a follow-up in its thread (`outreach-drafter`, checked by `email-draft-judge`) and sends it with `mail.reply`, which waits for the person's approval. A target still unanswered 4 days after `sent_3` is closed as `closed_no_reply`; no thread gets more than two follow-ups. | Weekdays at 16:00 UTC, with up to 1,800 seconds of random delay: `{cron: "0 16 * * 1-5", timezone: "UTC", jitter_seconds: 1800}` |

A default schedule is a recommendation and nothing more: registering a workflow creates no schedule. It is offered, pre-filled, when the person makes a schedule for the workflow, and the person may run a workflow on any number of schedules of their own, or start it from a conversation.

Every run starts by reconciling: each page in a `*_pending_approval` state is moved on by what the person decided (`approved_once`, `approved_always` or `auto_allowed` to the next state, with the sent message's `Message-ID`; `denied` or `auto_denied` to `draft_denied`; `expired` to `approval_expired`).

## Inputs

| Input | Workflows | Meaning |
| --- | --- | --- |
| `mailbox` | all | The address of the connected mailbox. |
| `notes_workspace` | all | The Nuclear Notes workspace that holds the pages. |
| `page_prefix` | all | The path the pages live under; default `outreach`: thread pages at `<page_prefix>/threads/<mailbox>/<key>` (`<key>` the first 16 hexadecimal digits of the SHA-256 of the thread's id, kept whole in the page's `thread_id`), target pages at `<page_prefix>/targets/<domain>/<local-part>`. |
| `evidence_paths` | `email-inbox-triage` | The pages a reply may take facts from. |
| `draft_only` | `email-inbox-triage` | Save replies as drafts instead of sending them; default false. |
| `opt_out_sentence` | `email-outreach`, `email-followup` | The sentence that lets the reader say no to further email; every first email ends with it. |
| `postal_address` | `email-outreach`, `email-followup` | The sender's postal address; every first email carries it. |

## Agents

| Agent | Model alias | Tools | Answers |
| --- | --- | --- | --- |
| `mail-triage-agent` | `default` | `mail.read` | `{threads: [{thread_id, category, needs_reply, summary}]}`, category one of `support`, `sales_lead`, `partner`, `reply_to_outreach`, `spam`, `other` |
| `mail-reply-drafter` | `smart` | `mail.read`, `mail.draft`, `nuclear-notes.pages.read` | `{replies: [{thread_id, to, cc, subject, body, evidence}]}` |
| `outreach-drafter` | `smart` | `nuclear-notes.pages.read`, `mail.draft` | `{emails: [{target_page, to, published_at_url, thread_id, subject, body, evidence}]}` |
| `mail-triage-judge` | `judge` | none | a score and its reasons |
| `email-draft-judge` | `judge` | `nuclear-notes.pages.read` | a score and its reasons; it reads the evidence pages the writer read and, for each fact an email states about the company, a product or a person, cites the passage it rests on or says "no passage" (the writer's own quotes alone do not count), failing a fact with no passage and a description of a product the pages do not state |
| `email-loop-clerk` | `default` | `mail.list`, `mail.read`, `mail.label`, `mail.draft`, `mail.send`, `mail.reply`, `aegis.approval.status`, `fs.write`, `cmd.run`, `nuclear-notes.pages.list`, `nuclear-notes.pages.read`, `nuclear-notes.pages.create`, `nuclear-notes.pages.patch_metadata`, `nuclear-notes.pages.apply_patch` | what each bookkeeping step did; it does only the workflows' bookkeeping (listing, labelling and flagging threads, keeping the pages, reading what the person decided on each waiting send) and sends or saves only text that passed `email-draft-judge`, exactly as given; a send step whose send tool (`mail.send` for a first email, `mail.reply` for a follow-up or a reply that is not a draft) is not among its tools saves no draft, changes no page and answers `failed`, and the run ends at `FAILED`; it calls `mail.draft` only when `email-inbox-triage` runs with `draft_only` true; it writes no text of its own and has no judge; it declares a read-write volume at `/workspace` for the thread-ids file, which inside a workflow yields to the workflow's workspace; one try of a step lasts at most 900 seconds and a whole step at most 1,800 |

A draft passes at a judge score of 0.8 or above; below it the drafter writes it again, at most three times, and a draft that never passes is recorded on its page as `draft_rejected_by_judge` and not sent. `email-draft-judge` fails an email that commits to a payment, price, discount, agreement, exclusivity or delivery date; that claims or implies the sender is a human; that states a fact no evidence page holds; that, as a first email, lacks the opt-out sentence or the postal address; or that is addressed anywhere but an address the organisation publishes for that purpose.

Each clerk step is sized to fit one try: labelling and recording are separate steps of `email-inbox-triage`, a run sorts at most 10 threads, and a step computes the keys of all its threads with one command (the ids written one per line to `/workspace/thread-ids.txt`, then each line's SHA-256), never one command per thread. The 10 threads, 900 seconds and 1,800 seconds are starting values, not measurements; the rounds each step takes are read from a scheduled run and the values set from them.

Each agent that calls a `mail.` tool declares the `imap` context as required, and each that calls a `nuclear-notes.` tool declares `nuclear-notes` as required: a run whose schedule or conversation chose no binding for one of them is refused at start.
