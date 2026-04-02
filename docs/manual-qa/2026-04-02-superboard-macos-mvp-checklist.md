# Superboard macOS MVP Manual QA

- Launch the app and grant Accessibility permission when prompted.
- Copy plain text from TextEdit, press `Cmd+Shift+V`, choose the first item, verify it pastes immediately.
- Copy an image from Preview, press `Cmd+Shift+V`, choose it, verify the target app receives an image paste.
- Copy one Finder file and then multiple Finder files, press `Cmd+Shift+V`, choose each entry, verify the target app receives file paste payloads.
- Copy more than 10 items, press `Cmd+Shift+V`, verify only the 10 most recent are shown.
- Verify the picker appears near the active editing context or focused window rather than as a full app switch.
