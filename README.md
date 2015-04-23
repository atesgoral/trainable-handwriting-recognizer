# Trainable Handwriting Recognizer

_March 1993_

Prototype for a high school term project. Done using Pascal with lots of inline 68000 assembly.

In training mode, uses a [Karhunen–Loève transform](http://en.wikipedia.org/wiki/Karhunen%E2%80%93Lo%C3%A8ve_theorem) to normalize the orientation and scaling of letters drawn with the mouse and applies the normalized bitmap data to a training matrix. Then, in recognition mode, applies the same transformation to drawn letters to guess them with a simple weighted comparison against the training matrix.

**The indentation is awful. Plain awful.**
