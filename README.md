# Guild Contributions Addon

This is an addon for Elder Scrolls Online to manage required contributions to guilds.

# How it works

For each guild you're in there are two policies that determine how contributions work.

## Rules

A rule defines when a contribution is required (how often, etc...).  Generally, contributions via the window are not permitted unless the contribution is considered "due" by the rule; this is to prevent accidental over-giving via the GuildContributions UI elements.  So for rules that define a due date, it should be set to the day after it is actually required by the guild leaders.

The following rules are defined.

### None

No contributions are required, and you will not receive reminders about it.  This is the default setting.

### Weekday

Contributions are weekly, due on the specified day of the week.

Options:

* Day - Day of the week which you consider this "due":
	* Contributions are considered due at the beginning of this day.
	* Contributions are considered late at the beginning of the next day. 
	* When you change this setting, it will target the NEXT occurrence of this day.

## Methods

A method defines HOW to contribute:

### Manual

Contributions are simply annotated, no gold is transferred automatically.  This is the default setting, and should be used for complex contribution requirements.

### Guild Bank

When the guild bank is open, you may deposit gold to the bank via the UI button.

Options:

* Depost Gold - Amount of gold to deposit to the bank

### Mail

When the mailbox is open, you may send gold via the UI button.

Options:

* Gold - Amount of gold to send (1-10000)
* To - Recipient of gold
* Subject - Subject line for the mail
* Body - Body text (200 char max)

***THIS WILL INCUR POSTAGE COSTS!***

# Developer Feedback

Please use the issue tracking system in github for feature requests.  Bugs should be submitted there too, but likely will end up on the comment section of esoui.

## About the Developer(s)

### okulo

I am the original author of this addon.  I am also a Senior Software Engineer at a large company and I have a family including two kids, so I am VERY busy.  I can't guarantee any appropriate level of responsiveness.  Due to my other commitments, I have no plans to develop any complex features for the addon; but I hope to stay on top of simple bug fixes.  My busy schedule is a major factor in my decision to host publicly on GitHub, so other interested developers can fork or contribute.

# Contributing

Interested in becoming a contributor?  Please create an issue in the GitHub issue tracker with the appropriate information.