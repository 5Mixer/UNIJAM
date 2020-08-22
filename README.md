# UNIJAM

*The beginning of a great crusade.*

**Theme**: "Connections".

IMPORANT:
- No initial transitionTo calls for objects.

TODO:
- Optimise item offsets for SKETCHING (actual raw point is still unoffset)
- Sword pinpoint sharpness when moving
- Axe rotation and angular momentum
- Glitch when collide with vertical wall - crawls up
- Knife projection:
    - Dampening constant velocity
    - CURRENTLY no distance constraint
- Knife collision
    - If it hits enemies: acc./veloc. decreases
- Soul retrieval:
    - Summon back with a click AT ANY POINT (give it a 'up then retrace' vibe)
    - WITH A WALL: Switch to 'soul retract' mode
- Soul exchange:
    - Consider doing so AT ANY TIME?
- Sound:
    - Movement
    - Bat?
    - Knife slash ... overlaying with a spriitually vibe.

Design choice:
- Soul is ABC (null = soul is in body) all types subclass