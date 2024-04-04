# latex template for correctexam

The goal of this repo to to share update on correct exam latex template


## Removed spacing in `\fbox` and consequences

By design, this class sets the `fboxsep` length to `0`, which removes the inner spacing inside an `fbox`. 
Not only does this affects the `\fbox` command, but this also affects all packages that rely on `fboxes` to draw frames.

For example, the `minted` package provides a `frame` option which underneath relies on `fbox` to display lines or boxes around a code listing.
Fortunately, `minted` provides a `framesep`  option which can be used to explicitly increase the spacing, and therefore "fix" (or compensate) the problem explained above:

```latex
\setminted{frame=lines,framesep=5pt}
```