<!-- gf-brief source=1ed7b1c1fe2e778a389ca50e581f900ee76237d68986407db5c5a13b947b9d4d written=2026-10-14T18:27:31+03:00 -->
# Tabulator

## What it is
Tabulator is a punch-card picker for people who need one honest pick from typed names. You add rows, punch the names still in play, then tap Read so one of those punched rows files as the pick. There are no weights, no wheel, and no scored list.

## Launch and onboarding
The icon and home-screen name are **Tabulator**. The app opens in dark appearance. The system launch screen has no wordmark or buttons.

On a device, a first launch that has never finished the intro shows three pages. **Skip** is always at the bottom. The primary button is **Next** on the first two pages and **Continue** on the last. Skip and Continue both end the intro and open the card.

1. **The card** — “The card holds the rows still in play.” **Skip**. **Next**.
2. **Punch, then Read** — “Punch a hole so the row can win. Read files one pick.” **Skip**. **Next**.
3. **Peel** — “Peel drops the newest verdict. History keeps the file.” **Skip**. **Continue**.

After the intro, a card with no rows is the empty home state. On the Simulator, a first run can skip the intro and open a card that already has rows and filed verdicts (see Starter content).

There is no sign-in and no permission prompt on launch.

## Screens

There is no tab bar. The card stays on screen. History, Settings, and Tie open over it. Read and Peel on the card stay on the card.

### The card
No navigation title. The large word is the card’s state: **Blank** when there are no rows; **Open** when rows exist but none are punched; **Punched** when at least one hole is in play and no pick is waiting; **Read** in the waiting fold. After a successful Read, that large word becomes the filed name.

Under the word:
- **Punch rows, then Read.** when no pick is waiting.
- **Verdict filed. Peel to read again.** when a pick is waiting.

A count line reads **Punched** plus the locale-formatted number of punched rows. After a refused Read it becomes **Spar. Punch two rows.**

Controls:
- **History** — opens History over the card.
- **Settings** — opens Card settings over the card.
- **Type a name** — text field. Done adds a row if the text is not empty, then clears the field. An empty Done does nothing. Tapping outside or scrolling the list dismisses the keyboard.
- **Tie** — opens Tie over the card.
- Each row shows the typed name and a hole labeled **In** (punched, can win) or **Out** (not in the draw). Tapping the hole flips that row. VoiceOver on the hole is **Punch** plus the name, or **Unpunch** plus the name.
- **Peel** — enabled only while a pick is waiting. Drops the newest verdict from the card so Read can run again. Rows and History stay. Disabled (dimmed) when no pick is waiting.
- **Read** — files one pick from punched, non-blank rows. After a file, Read is disabled until Peel. VoiceOver then says **Read waits for Peel**. If fewer than two punched non-blank rows are in play, Read does not file; the button title becomes **Spar** and the count line becomes **Spar. Punch two rows.** The card stays. A new row starts as **Out**.

Empty card (no rows):
- **Card is blank**
- **Type two names.**
- **Add a row** — alert **Add a row**, “Type a name.”, field **Type a name**, **Cancel**, **Add a row**. Cancel dismisses. Add a row with a blank field does nothing. A typed name adds that row and shows the card.

If the stored card cannot be read:
- **Card failed**
- **Stored card could not be read.**
- **Start blank** — clears the failed state and leaves an empty card.

### History
Opened by **History**. No title on the sheet. **Close** (with an X) dismisses back to the card.

When verdicts exist, each card shows the filed name and a line **Verdict** plus the locale-formatted order, a period, then the day in the device’s medium date style (for example Verdict 1. Oct 13, 2026). The list is oldest to newest and grows with each successful Read. Peel does not remove these cards.

Empty:
- **No verdicts**
- **Read the card to file a pick.**
- **Read** — closes History and returns to the card. It does not file a pick.

If stored verdicts cannot be read:
- **History failed**
- **Stored verdicts could not be read.**
- **Retry** — clears the failed state.
- **Close** is hidden on this error page.

### Card settings
Opened by **Settings**. Title **Card settings**. **Close** (with an X) dismisses back to the card.

Always shown:
- **Seeded draw. Rows** *n* **. Verdicts** *m* **.** — *n* and *m* use the device’s decimal grouping.
- **Show the card intro** — closes settings and shows the three intro pages again. The card is not erased.
- **Contact Support** (two lines; VoiceOver **Contact support**) — opens the support page.
- **Erase card** (heading) — “Erase card removes the rows and the verdicts.”
- **Erase card** (button) — alert **Erase card**, “Rows and verdicts will be erased.”, **Cancel**, **Erase card**. Confirm wipes rows and verdicts. The empty document also returns the intro flag to unfinished, so after Close the three intro pages can appear again.

When rows and verdicts are both empty:
- **No card on file**
- **Rows and verdicts are empty.**

If the stored card cannot be read:
- **Settings failed**
- **Stored card could not be read.**
- **Retry**

### Tie
Opened by **Tie** on the card. Title **Tie**. Line: **Two names, even chance. Read files one of them.**

- **Left name** — text field.
- **Right name** — text field.
- **File the tie** — if both names are non-empty, replaces the card with those two rows already **In**, even chance, and dismisses to the card so Read can run. History is not cleared.
- If either field is empty, the title changes to **Spar** and nothing is filed.
- **Close** dismisses without changing the card.

### Read
A full-screen sheet for the same Read job. **Close** dismisses to the card.

When the card has rows:
- Large word: the filed name if a pick is waiting; otherwise **Blank**, **Open**, or **Read**.
- **Verdict filed. Peel to read again.** / **Spar. Punch two rows.** / **Punch rows, then Read.**
- **Rows** *n* **. Punched** *m* **. Verdicts** *k* **.**
- The first punched name, or **Blank**. Remaining punched names joined with “. ”. If only one punched row: **Punch a second row.**
- **Read** — files a pick when at least two punched non-blank rows are in play and no pick is waiting. Disabled while a pick is waiting (VoiceOver **Read waits for Peel**).

Empty: **Card is blank**, **Type two names.**, **Add a row** (closes the sheet; it does not add a row).

Error: **Card failed**, **Stored card could not be read.**, **Retry**.

### Peel
A full-screen sheet for the same Peel job. **Close** dismisses to the card.

When a verdict exists:
- **Pick**
- The newest filed name, **Verdict** plus the count, and the day in medium date style.
- While the pick is still held: “{name} is the pick. Peel puts this pick back.” and **Read waits until Peel clears this pick.** **Read** is disabled. **Peel** is enabled.
- After Peel: **Pick cleared. Read files the next pick.** and **Peel cleared this pick. Read is ready.** **Peel** is then disabled. **Read** is enabled and files the next pick.

Empty: **No verdict**, **Read the card to file a pick.**, **Read** (closes the sheet).

Error: **Card failed**, **Stored card could not be read.**, **Retry**.

## Features
- Punch-card of typed names (rows).
- Punch / Unpunch a hole: **In** or **Out**. Only **In** rows can win.
- **Type a name** to add a row (starts **Out**).
- **Read** files one pick from punched, non-blank rows (seeded draw, even chance among those rows).
- **Spar** when Read runs with fewer than two punched rows; the card is kept.
- **Peel** drops the newest verdict so Read can run again. Rows and History stay.
- **History** lists filed verdicts in order.
- **Tie** — two names, even chance, both already punched.
- **Seeded draw** named on Card settings, with row and verdict counts.
- **Show the card intro** to replay the three pages.
- **Erase card** after a confirm.
- **Contact Support** opens the support page.

## Behaviours that can look like bugs
- After a successful Read, **Read** will not run again until **Peel**. The hint is **Verdict filed. Peel to read again.** Peel, then Read.
- **Peel** is dimmed until a pick is waiting. File a Read first.
- **Read** with fewer than two punched, non-blank rows does not file. The button becomes **Spar** and the line **Spar. Punch two rows.** Punch two rows **In**, then Read.
- A new row is **Out**. Punch it **In** or it will not enter the draw.
- A whitespace-only name does not enter the draw even if the hole is **In**.
- Empty home **Add a row** with a blank field adds nothing. Type a name, then **Add a row**.
- **File the tie** with a blank Left or Right name changes the title to **Spar** and stays on Tie. Fill both fields.
- **File the tie** replaces every row on the card with the two typed names. History verdicts remain.
- Punching **In** / **Out** after a pick is filed does not change that pick. Peel first if you need to Read again.
- History grows with each Read. Peel does not delete old verdicts.
- **No verdicts** / **Read** only closes History. File a pick on the card, then open History again.
- **Card is blank** until at least one row exists. Add two names and punch two holes before a successful Read.
- **Card failed** / **Start blank** or **Retry** after a stored card cannot be read. Start blank or Retry, then type rows again.
- **Show the card intro** returns to the three pages on purpose. Skip or Continue to get back to the card.
- **Erase card** wipes rows and verdicts. After Close, the intro can appear again because the card is empty. Finish the intro, then **Add a row**.
- **Read** on the empty Read or Peel sheet only closes that sheet.

## Starter content and resume
On the Simulator, a first run can skip the intro and seed three punched rows: **Mara Quill**, **Owen Pike**, **Lina Voss**. Read is already legal. History already holds at least three verdicts from those names. That seed does not run on a physical device.

On a device, there is no sample card. After the intro the card is blank until the user types names.

Rows, punches, and verdicts persist. A filed pick that is still waiting is still waiting after relaunch; Peel, then Read. An unfinished intro shows again on the next launch until Skip or Continue. Erase card clears the card.

## Permissions
None.

## Absent
Genuinely absent: login or accounts, in-app purchase, ads, analytics, user-generated content, account deletion flow, App Tracking Transparency prompt.

## Data and support
Everything stays on this device. **Contact Support** on Card settings opens the support page.

## Scanning and health
None.

## Platform
English UI only. Counts and History dates follow the device locale and calendar. No region lock. Portrait only, iPhone and iPad, dark appearance. Minimum iOS 17.0.

## Category
Lifestyle
