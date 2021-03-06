# Chapter 28

- Basic libraries and data structures
    - Choosing the right data structures is critical to performance and
      performance optimization in Haskell

- Benchmarking with Criterion
    - Can sample performance using Monte Carlo method
    - [`criterion`](http://hackage.haskell.org/package/criterion): Haskell
      performance analysis and measurement
    - While compiling code for benchmarking, use `-O` or `-O2` in build flags to
      GHC
        - `stack ghc -- -O2 bench.hs`

- See `Bench.hs`.

```haskell
Prelude> :l Bench.hs
[1 of 1] Compiling Bench            ( Bench.hs, interpreted )
Ok, one module loaded.
*Bench> main
benchmarking index list 9999
time                 19.30 μs   (18.96 μs .. 19.70 μs)
                     0.997 R²   (0.994 R² .. 0.999 R²)
mean                 19.11 μs   (18.93 μs .. 19.39 μs)
std dev              743.4 ns   (441.2 ns .. 1.238 μs)
variance introduced by outliers: 46% (moderately inflated)

benchmarking index list maybe index 9999
time                 5.906 ms   (5.778 ms .. 6.038 ms)
                     0.997 R²   (0.994 R² .. 0.999 R²)
mean                 5.796 ms   (5.745 ms .. 5.873 ms)
std dev              192.4 μs   (131.0 μs .. 286.3 μs)
variance introduced by outliers: 15% (moderately inflated)
```

- Making the case for nf
    - See `NF.hs`.

- Profiling your programs
    - https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/profiling.html

- Profiling time usage
    - See `ProfilingTime.hs`.

- Profiling heap usage
    - See `Loci.hs`.

- (PERSONAL NOTE: Somehow getting incorrect binaries with ProfilingTime.hs and
  Loci.hs; `Unable to run executable: exec format error` or similar. Skipping
  for now but cannot generate .prof reports.)

- Constant applicative forms
    - See `ApplicativeForms.hs`.
    - CAFs trade memory usage for time, and aren't relevant beyond toy projects

- Map
    - [`containers`](http://hackage.haskell.org/package/containers) is where
      most of these data structures are hosted

- See `MapBench.hs`.

- Set
    - `Ord` typeclass constraint
    - Unique, ordered set of values
        - (PERSONAL NOTE: This is different from Python, where sets are
          unordered)

```haskell
data Set a
    = Bin
        {-# UNPACK #-}
        !Size !a !(Set a) !(Set a)
    | Tip

type Size = Int
```

- See `SetBench.hs`.

********** BEGIN EXERCISE: BENCHMARK PRACTICE **********

(SKIPPING FOR NOW)

********** END EXERCISE: BENCHMARK PRACTICE **********

- Sequence
    - Finger trees: http://www.staff.city.ac.uk/~ross/papers/FingerTree.html
    - Sequence builds on finger trees: cheap appends to front and back (unlike
      list, which is only cheap appends to the front)

```haskell
newtype Seq a = Seq (FingerTree (Elem a))

newtype Elem a = Elem { getElem :: a }

data FingerTree a
    = Empty
    | Single a
    | Deep  {-# UNPACK #-} !Int !(Digit a)
            (FingerTree (Node a)) !(Digit a)
```

- See `SeqBench.hs`.

- What's slower with Sequence?

- Vector
    - https://hackage.haskell.org/package/vector
    - Use instead of `array`

```haskell
data Vector a =
    Vector  {-# UNPACK #-} !Int
            {-# UNPACK #-} !Int
            {-# UNPACK #-} !(Array a)
    deriving Typeable
```

- Vectors can come in many variants: boxed, unboxed, immutable, mutable,
  storable, plain, etc.
    - Boxed: reference any datatype
    - Unboxed: raw values without pointer indirection
    - Saves memory at the cost of having more restricted types

- When does one want a Vector in Haskell?
    - Want memory efficiency close to theoretical max
    - Data access is through indexing
    - Uniform access times
    - Write once, read many

- What about slicing?
    - See `SlicingBench.hs`.
    - Slicing vectors is a lot faster than slicing lists, because vectors reuse
      the underlying snapshot of data
    - (PERSONAL NOTE: This reminds me of Clojure's atoms and CRDTs)

- Updating vectors
    - Fusion: See Stream Fusion by Duncan Coutts
        - As an optimization, compiler can fuse several loops into one large
          loop and do it in one pass.
    - See `Fusion.hs`.
    - Fusion isn't a catch-all benefit
        - See `UpdateVector.hs`.
    - Could go faster by lazily constructing updates and flushing all at once

- Mutable Vectors
    - See `MutableVectors.hs`.

- A sidebar on the ST Monad
    - ST can be thought of as a mutable State monad
    - It's "morally effect-free"
        - Lazy Functional State Threads, by John Launchbury and Simon
          Peyton-Jones

********* BEGIN EXERCISES: VECTOR *********

(SKIPPING FOR NOW)

********* END EXERCISES: VECTOR *********

- String types
    - String: type alias for [Char]
    - Text: Plain text you need to store efficiently
        - hackage.haskell.org/package/text
        - UTF-16 encoded, not UTF-8

- Don't trust your gut, measure
    - See `MemoryProfiling.hs`.

- ByteString
    - Sequence of bytes represented as `Word8` values
    - Doesn't have encoding
    - You can use GHC extension OverloadedStrings
    - Might not be comprehensible

    - See `BS.hs`.

- ByteString traps
    - Don't use `Char8` to cast String to ByteString; will destroy Unicode data
    - See `Char8ProllyNotWhatYouWant.hs`.

- When would I use ByteString instead of Text for textual data?
    - If you read UTF-8 data from file/network and you don't want to cast to
      different byte encodings

********** BEGIN CHAPTER EXERCISES **********

(SKIPPING FOR NOW)

********** END CHAPTER EXERCISES **********
