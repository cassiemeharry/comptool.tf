# comptool.tf

This is the back end for a collection of tools for competitive TF2. These will
serve four main audiences:

  * Players. Without them, competitive TF2 is dead.
  * Teams, to relieve some pressure points and help players stick around.
  * Casters, to make their job so much easier.
  * Spectators, so that everyone can have something to gossip about.

## casters.comptool.tf

This tool is for some of the MVPs of the competitive TF2 community, the
casters. A mostly thankless job, they do their best to keep a match interesting,
even if one team is getting rolled.

Without a tool like this, casters are at a disadvantage. Often times, they will
miss the big plays, and with so many teams out there, they often don't know much
about the players they're casting. This makes for a boring/frustrating casting
experience.

### Sub-Tools:

  * A mini-map, so casters can know where everyone is at a given moment.

  * An ahead-of-time event feed, so casters can be in position to catch the huge
    plays. SourceTV runs on a delay, so with a server plugin, we can stream out
    events on a `tv_delay - 30` second delay.

  * A not-so-random stats box, which shows stats relevant to one of the players
    in the event feed.

    For example, if the event feed shows a medic dropping über, then the stats
    box could say something like this:
    
    > PlayerNameHere, the BLU Medic, just dropped their fifth über of the
      season.

### Caveats:

  * This would require some kind of two-way authentication mechanism, to prevent
    anybody from looking at their own match and cheating.

  * This also requires a server plugin. I've considered ways to do without that,
    but they're all crazy-difficult. Maybe someday...

# Motivation

I've been asked, "Why are you doing this?"

That's a fair question. This all started as a reaction to
[this Reddit post][tf2-as-basketball]. After reading that, something felt very
off. While I agreed that there was something to be done about making competitive
TF2 more interesting to watch, I was fairly sure it couldn't be done by trying
to change up the format. Games are very carefully balanced things, and by
changing up the format, you both upset the player-base and possibly topple the
whole thing. This problem needed to be approached from a different angle.

I started reading up peoples reactions, and a lot of the complaints were about
how TF2 is not designed as an e-sport, and the spectator tools reflect
that. This in turn leads to low-quality casting. It occurred to me that a better
casting tool could fix that, by providing casters the information they need,
since TF2 doesn't by default.

The other thing I took issue with was the comparison to basketball. If you're
going to compare TF2 to a major physical sport, baseball is a much more apt
comparison. Lots of waiting around, strats, and stats. Pretty much everyone I've
talked to about baseball tells me that it's the stats that keep them engaged.

There seems to be an open-data movement going on within the TF2 community, and
while some aggregation is going on, it's not exactly caster friendly. If I
incorporated those stats into the aforementioned caster's tool, then the casters
would have something to talk about during the down time.

By giving casters better tools, I can feel more free to point my non-TF2 playing
friends and family to watching high-end games. With more information available,
casters can spend more time talking about the players and the game, and less
time talking about what the scout is doing so far away from the real
action. Overall, this should raise the excitement level of the game to something
that will keep non-competitive players engaged.

**I'm doing this because I want to see competitive TF2 grow.**

I should note that I don't intend to make money off this. Server costs should be
minimal, at least to start off with. Maybe down the road if/when TF2 takes off,
I may ask around for donations to support hosting, but this will never be a
for-profit business. Casters and players have enough to deal with as-is, and
I've seen too many promising projects killed because they tried to monetize too early.

[tf2-as-basketball]: http://www.reddit.com/r/truetf2/comments/17q9ip/big_changes_are_coming_in_competitive_tf2/
