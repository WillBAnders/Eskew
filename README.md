# Eskew

A stack inspired language made for RacketCon 2019

## Overview

Eskew is a language extension for Racket with the following goals:

 - Be stack based
 - Use Racket macros
 - Have something unique

There is no practical purpose for Eskew, just experimentation and practice.

## Download

Eskew can be installed as a Racket package in DrRacket through GitHub.

## Workspace

The design of Eskew is based around stacks and queues (s-q), as well as various combinations that result. There are four data structures (which act similarly to channels) that are 'located' on each side of the screen, called the workspace.

```
           Console
      ╔═══════════════╗
      ║               ║
Stack ║               ║ Queue
      ║               ║
      ╚═══════════════╝
         Environment
```

Elements can be moved from one structure to another using unicode arrows. For example, `↓` sends an element from console to the environment (input), `↖` sends an element from the stack to the queue, and `→` sends an element from the stack to the queue.

A simple program that prints the users input would thus be:

```racket
↓ ;Sends an element from console to the environment
↑ ;Sends an element from the environment to console
```

See the section on movement actions below for a complete list.

## Actions

Actions are used to manipulate the strutures available and are generally unicode characters. These have been grouped into a couple of categories, roughly increasing in complexity.

> See [Keyboard Shortcuts](https://docs.racket-lang.org/drracket/Keyboard_Shortcuts.html) for entering unicode characters in DrRacket.

### Literals

Any literal number is sent to the environment. Negative numbers, fractionals, and even complex numbers are supported.

> See the [Numbers](https://docs.racket-lang.org/reference/numbers.html) section of the Racket docs for more information on number types.

### Operations

Eskew supports basic arithmetic operations and comparison. Each of these operators consume two elements from the environment and returns the result onto the environment.

```
+ ;Addition
- ;Subtraction
* ;Multiplication
/ ;Division
= ;Equality
≠ ;Inequality
```

### Movement

Movement actions send elements between structures in Eskew. See the core methology section above for an explanation and diagram.

```racket
↓ ;Sends an element from console to the environment
↑ ;Sends an element from the environment to console
↖ ;Sends an element from the environment to the stack
↘ ;Sends an element from the stack to the environment
↗ ;Sends an element from the environment to the queue
↙ ;Sends an element from the queue to the environment
```

> There are no actions between the stack/queue and console.

### Environment

These actions manipulate the environment, which is effectively a deque.

```racket
. ;Duplicates the first element in the environment
: ;Reverses the environment
```

### Loops

Loops start with `⊏` and end with `⊐`, acting like while loops using the first element from the environment. If the element is zero the loop ends (or never begins), else the loop iterates. Note that an element from the environment is consumed.

```
⊏ ;Begins a loop
⊐ ;Ends a loop
```

Loops are also the only conditional construct. Pushing `0` before ending a loop will always exit, so this may be used similarly to an if statement.

## The Eskew

Earlier, the workspace was explained as having a stack to the left and a queue to the right. In relality, this isn't exactly true - the left and right sides are both connected to the same data structure called an eskew.

An eskew acts exactly like a stack on the left and a queue on the right, except for when attemting to remove an element when a side is empty. Instead of failing, the eskew goes the other side and retrieves an element using the same strategy. Explicity:

 - If the stack is empty, removing an element will retrieve the *last* element added to the *queue*, using the queue as a LIFO data structure.
 - If the queue is empty, removing an element will retrieve the *first* element added to the *stack*, using the stack as a FIFO data structure.
 - If both are empty then the program fails.

> There is currently no practical justification for this - it's just for fun. If you discover a program that makes use of this function, please reach out to me.

## Example Programs

### AddMul

Returns `#t` (1) if `(+ x y)` and `(* x y)` are equal for inputs `x` and `y`. Pairs `(0, 0)` and `(2, 2)` return true; there may be other solutions in complex/fractional numbers.

```
↓ . ↖
↓ .
↘ + ↖
*
↘ =
↑
```

### Echo

Takes in multiple, non-zero inputs (terminating on zero) and prints them in the order given.

```racket
0 ↖         ;1: Pushes 0 to the stack (used as counter)
1 ⊏         ;2: Begin input loop (1 = true)
 0          ;3: Pushes 0 to be used for exiting loop
 ↓ .        ;4: Retrieves an input number and duplicate
 0 ≠ ⊏      ;5: Enter the loop if the input was not zero
  ↗         ;6: Add the input to the queue
  ↘ 1 + ↖   ;7: Retrieve the counter and increment by 1
  0 =       ;8: Consume 0 from line 3 and push 1 for outer loop
  0         ;9: Push 0 to break out of current loop
 ⊐          ;10: Inner loop close
⊐           ;11: Outer loop close
↘ .         ;12: Retrieve the counter and duplicate it
0 ≠ ⊏       ;13: Enter the loop if the counter is not zero
 ↙ ↑        ;14: Print the next element from the queue
 -1 + .     ;15: Subracts 1 from the counter and duplicates it
 0 ≠        ;16: Pushes 0 if the counter is 0 to exit the loop
⊐           ;17: Loop close
```
