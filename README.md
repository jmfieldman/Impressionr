Impressionr
===========

<a href="https://itunes.apple.com/us/app/impressionr/id863253119">App Store Link</a>

<a href="http://fieldman.org/impressionr">Website</a>

*For too long you have stared at your photos, the images capturing life with excess realism. This is not the world you see. Your passion consumes you with the desire to transform the humdrum of life into the wildness of your dreams. You despair, for it seems there is no escape. Until now. Awaken, friend, and know that with this app your mental prison cannot contain you any longer.*

I stumbled across <a href="http://mattdesl.github.io/impressionist/app/">a really cool web app</a>. It takes a photo and continuously strokes lines above it to create an impressionist-ish effect.

I thought it would be fun to implement as an app, and set to work. I started on a Thursday and finished the following Tuesday. It was a fairly straightforward app, but there were some tricky issues optimizing the drawing code to give decent frame rates. The app draws to a memory buffer, so it's very CPU-dependent.

Here's one of the really annoying drawing issues I had to deal with. To animate the lines, they needed a velocity and lifetime. Each frame, I calculate the distance a line has moved and draw a fragment of the line from the start->end position. The line position is updated and the process repeats each frame. To give the lines a "stroke" feel, they have round end caps. When lines have a non-one alpha (i.e. somewhat transparent), the line caps from a new fragment draw over the old cap, making a dark circle where fragments overlap. In order to fix this, I had to create a clipping mask, *unique for each stroke*, that prevented drawing in old cap area for that line. This dropped frame rate significantly, but was graphically necessary. I minimized the hit by reducing the clipping rectangle to cover just the stroked line (since, oddly, the clipping area seemed to heavily affect frame rate).

I also decided to play around with some UI concepts, and think I came up with a relatively nice and light-feeling UI.

I was a bit disappointed with Instagram. There is no way to post to Instagram from inside an app; you have to use the document sharing mechanism to open the image in the Instagram app. It was kind of an ugly multi-step flow.

License
-------

Impressionr source code is distributed under the GPL v3 license.  See License.md for details.