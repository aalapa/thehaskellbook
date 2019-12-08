# Chapter 7

- More functional patterns
    - Functions are first-class values in Haskell
    - First class value: Values that can be used as arguments to a function

- Setting parameters
    - Functions differ from values because they apply parameters to arguments

```haskell
Prelude> myNum :: Integer; myNum = 1
Prelude> myVal = myNum
Prelude> :t myVal
myVal :: Integer
Prelude> myVal f = myNum
Prelude> :t myVal
myVal :: p -> Integer
Prelude> myVal f = f + myNum
Prelude> :t myVal
myVal :: Integer -> Integer
Prelude>
```

- Applying more parameters results in generating a partially applied (but still
  valid) function

```haskell
-- f g not used
Prelude> myVal f g = myNum
Prelude> :t myVal
myVal :: p1 -> p2 -> Integer
-- f g h not used
Prelude> myVal f g h = myNum
Prelude> :t myVal
myVal :: p1 -> p2 -> p3 -> Integer
Prelude>
```

- Scoping / binding variables to values
    - Applying a function binds parameters to values
    - Type parameters are bound to concrete types
    - Function variables are bound to concrete values

```haskell
Prelude> :{
Prelude| addOne :: Integer -> Integer
Prelude| addOne x = x + 1
Prelude| :}
Prelude> addOne 1
2
Prelude> addOne 1 = 1 + 1
-- An error occured when accepting to reuse method `addOne`, as explained here:
-- https://stackoverflow.com/a/26738476
--
-- Add to a file and :load into GHCi
--
-- Error may be because using single equals instead of double equals
Prelude> addOne 10
*** Exception: <interactive>:18:1-16: Non-exhaustive patterns in function addOne
```

See `scoping.hs`.

- Anonymous functions

```haskell
Prelude> :{
-- Normal named method
Prelude| triple :: Integer -> Integer
Prelude| triple x = x * 3
Prelude| :}
Prelude> :{
-- Anonymous / lambda method
Prelude| (\x -> x * 3) :: Integer -> Integer
Prelude| :}

-- Method does not implement
<interactive>:46:1: error:
    • No instance for (Show (Integer -> Integer))
        arising from a use of ‘print’
        (maybe you haven't applied a function to enough arguments?)
    • In a stmt of an interactive GHCi command: print it
Prelude> :{
-- Assigning a lambda method to a variable
Prelude| let trip :: Integer -> Integer
Prelude|     trip = \x -> x * 3
Prelude| :}
-- Need to wrap lambda methods in parentheses in order to apply to variables
Prelude> (\x -> x * 3) 5
15
-- Otherwise this happens
Prelude> \x -> x * 3 1

-- I get a different error than the book
--
-- But difficult to deduce that 1 is an argument and not part of the method
-- definition.
<interactive>:57:1: error:
    • Non type-variable argument in the constraint: Num (t -> a)
      (Use FlexibleContexts to permit this)
    • When checking the inferred type
        it :: forall a t. (Num a, Num t, Num (t -> a)) => a -> a
Prelude>
```

********** BEGIN EXERCISES: GRAB BAG **********

1. b), c) and d) look equivalent to me.

(INCORRECT, they all appear to compile and share happy path runtime behavior, so
I would say that they are all the same.)

```haskell
Prelude> mTh1 x y z = x * y * z
Prelude> mTh1 1 2 3
6
Prelude> mTh2 x y = \z -> x * y * z
Prelude> mTh2 1 2 3
6
Prelude> mTh3 x = \y -> \z -> x * y * z
Prelude> mTh3 1 2 3
6
Prelude> mTh4 = \x -> \y -> \z -> x * y * z
Prelude> mTh4 1 2 3
6
Prelude>
```

2. c) / `mTh 3`, because there is one input argument. b) is the type of `mTh 3`.

(CORRECT)

```haskell
Prelude> :t mTh3
mTh3 :: Num a => a -> a -> a -> a
Prelude>
```

3. Below:

a) Below:

```haskell
addOneIfOdd n = case odd n of
    True -> f n
    False -> n
    where \n -> n + 1
```

(INCORRECT, entire method should be transformed to a lambda.)

```haskell
-- Original
Prelude> :{
Prelude| addOneIfOdd n = case odd n of
Prelude|     True -> f n
Prelude|     False -> n
Prelude|     where f n = n + 1
Prelude| :}
-- My solution
Prelude> :{
Prelude| addOneIfOddLambda n = case odd n of
Prelude|     True -> f n
Prelude|     False -> n
Prelude|     where \n -> n + 1
Prelude| :}

<interactive>:78:22: error:
    parse error (possibly incorrect indentation or mismatched brackets)
-- ANSWER KEY https://github.com/CarlosMChica/HaskellBook
Prelude> :{
Prelude| addOneIfOdd :: Integral a => a -> a
Prelude| addOneIfOdd = \x -> if odd x then f x else x
Prelude|   where f = (+ 1)
Prelude| :}
Prelude> addOneIfOdd 1
2
Prelude> addOneIfOdd 2
2
Prelude> addOneIfOdd 3
4
Prelude>
```

b) Below:

```haskell
addFive = \x -> \y -> (if x > y then y else x) + 5
```

(INCORRECT, got the wrong syntax and behavior and forgot type signature)

```haskell
-- My solution
--
-- 1. Should not have included parentheses excluding (+5)
-- 2. Do I need to pipe x and y separately?
Prelude> addFive = \x -> \y -> (if x > y then y else x) + 5
Prelude> addFive 5 10
10
-- hmm
Prelude> addFive 11 10
15
Prelude> addFive 5 11
10
Prelude> addFive 5 12
10
Prelude> addFive 5 115
10
Prelude> :{
Prelude| addFive :: (Ord a, Num a) => a -> a -> a
Prelude| addFive = \x y -> if x > y then y else x + 5
Prelude| :}
Prelude> addFive 5 10
10
Prelude> addFive 11 10
10
Prelude> addFive 5 11
10
Prelude> addFive 5 12
10
Prelude> addFive 5 115
10
Prelude>
```

c) Below:

```haskell
mflip f x y = f y x
```

(CORRECT)

********** END EXERCISES: GRAB BAG **********

- Most of the type lambdas are used in higher-order functions, and only when
  function is unique and does not need to be referenced later.

- Pattern matching
    - Match values against patterns, bind variables to successful matches.
    - Patterns: undefined variables, numeric literals, list syntax
    - Forms basis for effective multipledispatch

```haskell
Prelude> :{
-- Order of pattern matching matters! Always put the broader match after
-- narrower matches.
Prelude| isItTwo :: Integer -> Bool
Prelude| isItTwo 2 = True
-- Pattern match on anything else
--
-- GHC(i) should be raising a warning (or should be configured to raise a
-- warning using `:set -Wall`) if catch-all pattern behavior is undefined.
-- By default, Haskell will return "bottom", which will throw an exception.
Prelude| isItTwo _ = False
Prelude| :}
Prelude> isItTwo 2
True
Prelude> isItTwo 1
False
Prelude> isItTwo 100
False
Prelude>
```

- Pattern matching against data constructors
    - Vary what functions do given different inputs (decouple method definitions
      from input arguments)
    - Unpack and expose contents of data.

See `registeredUser1.hs`.

See `registeredUser2.hs`.

```haskell
Prelude> :l registeredUser2.hs
-- [1 of 1] Compiling RegisteredUser   ( registeredUser2.hs, interpreted )
-- Ok, one module loaded.
Prelude> :t RegisteredUser
RegisteredUser :: Username -> AccountNumber -> User
Prelude> :t Username
Username :: String -> Username
Prelude> :t AccountNumber
AccountNumber :: Integer -> AccountNumber
Prelude> printUser UnregisteredUser
UnregisteredUser
Prelude> myUser = Username "callen"
Prelude> myAcct = AccountNumber 10456
Prelude> :{
*RegisteredUser| let rUser =
*RegisteredUser|      RegisteredUser myUser myAcct
*RegisteredUser| :}
-- Method to unpack value `RegisteredUser`, and method varies based on different
-- type constructors.
Prelude> printUser rUser
callen 10456
Prelude>
```

See `wherePenguinsLive.hs`.

- Pattern matching tuples
    - You can use variables to match within tuples in the method definition just
      as in the type signature.

- See `matchingTuples1.hs`.

- Use GHCi's `:browse` method in order to see method type signatures for an
  entire module.

********** BEGIN EXERCISES: VARIETY PACK **********

1. Below:

a) The type of `k` should be `k :: (a, b) -> a`.

b) `k2` should be a concrete base type, because the value of `k2` can be fully
evaluated as `k` is applied to an input argument. The concrete base type is
`[Char]`. It will not be the same type as `k1` or `k3`, since those are `Num a
=> a`.

c) `k3`.

(ALL CORRECT)

```haskell
Prelude> k (x, y) = x
Prelude> :t k
k :: (a, b) -> a
Prelude> k1 = k ((4 - 1), 10)
Prelude> k2 = k ("three", (1 + 2))
Prelude> k3 = k (3, True)
Prelude> k1
3
Prelude> k2
"three"
Prelude> k3
3
Prelude> :t k1
k1 :: Num a => a
Prelude> :t k2
k2 :: [Char]
Prelude> :t k3
k3 :: Num a => a
Prelude>
```

2. Below:

```haskell
f :: (a, b, c) -> (d, e, f) -> ((a, d), (c, f))
f (a, b, c) (d, e, f) = ((a, d), (c, f))
```

(CORRECT)

```haskell
Prelude> :{
Prelude| f :: (a, b, c) -> (d, e, f) -> ((a, d), (c, f))
Prelude| f (a, b, c) (d, e, f) = ((a, d), (c, f))
Prelude| :}
Prelude> f (1, 2, 3) (4, 5, 6)
((1,4),(3,6))
Prelude>
```

********** END EXERCISES: VARIETY PACK **********

- Case expressions
    - Return a different result based on different inputs.

- Each time a case match or pattern match on a sum type (like `Bool`), we should
  define how we handle each case in the sum type. Otherwise, a runtime error
  could occur.

```haskell
-- Ternary syntax.
Prelude> funcX1 x = if x + 1 == 1 then "AWESOME" else "wut"
Prelude> funcX1 0
"AWESOME"
Prelude> funcX1 1
"wut"
-- Switch/case syntax.
Prelude> :{
Prelude| funcX2 x =
Prelude|   case x + 1 == 1 of
Prelude|     True -> "AWESOME"
Prelude|     False -> "wut"
Prelude| :}
Prelude> funcX2 0
"AWESOME"
Prelude> funcX2 1
"wut"
Prelude>
```

```haskell
-- Check palindrome, as switch/case syntax.
Prelude> :{
Prelude| pal xs =
Prelude|   case xs == reverse xs of
Prelude|     True -> "yes"
Prelude|     False -> "no"
Prelude| :}
Prelude> pal "abcba"
"yes"
Prelude> pal "abcd"
"no"
-- Check palindrome, using "where" clause.
Prelude> :{
Prelude| pal' xs =
Prelude|   case y of
Prelude|     True -> "yes"
Prelude|     False -> "no"
Prelude|   where y = xs == reverse xs
Prelude| :}
Prelude> pal' "abcba"
"yes"
Prelude> pal' "abcd"
"no"
Prelude>
```

See `greetIfCool3.hs`.

********** BEGIN EXERCISES: CASE PRACTICE **********

1. Below:

```haskell
functionC x y =
  case x > y of
    True -> x
    False -> y
```

(CORRECT)

```haskell
-- Original solution
Prelude> :{
Prelude| functionC x y = if (x > y) then x else y
Prelude| :}
Prelude> functionC 0 5
5
Prelude> functionC 5 5
5
Prelude> functionC 6 5
6
Prelude> :{
Prelude| functionC x y =
Prelude|   case x > y of
Prelude|     True -> x
Prelude|     False -> y
Prelude| :}
Prelude> functionC 0 5
5
Prelude> functionC 5 5
5
Prelude> functionC 6 5
6
Prelude>
```

2. Below:

```haskell
ifEvenAdd2_2 n =
  case even n of
    True -> n + 2
    False -> n
```

(CORRECT)

```haskell
Prelude> ifEvenAdd2 n = if even n then (n+2) else n
Prelude> ifEvenAdd2 1
1
Prelude> ifEvenAdd2 2
4
Prelude> ifEvenAdd2 3
3
Prelude> ifEvenAdd2 4
6
Prelude> :{
Prelude| ifEvenAdd2_2 n =
Prelude|   case even n of
Prelude|     True -> n + 2
Prelude|     False -> n
Prelude| :}
Prelude> ifEvenAdd2_2 1
1
Prelude> ifEvenAdd2_2 2
4
Prelude> ifEvenAdd2_2 3
3
Prelude> ifEvenAdd2_2 4
6
Prelude>
```

3. Below:

```haskell
nums x =
    case compare x 0 of
        LT -> -1
        GT -> 1
        EQ -> 0
```

(CORRECT)

```haskell
Prelude> :{
Prelude| nums x =
Prelude|     case compare x 0 of
Prelude|         LT -> -1
Prelude|         GT -> 1
Prelude|         EQ -> 0
Prelude| :}
Prelude> nums 0
0
Prelude> nums 2
1
Prelude> nums (-2)
-1
Prelude>
```

********** END EXERCISES: CASE PRACTICE **********

- Higher-order functions: functions that accept functions as arguments

```haskell
-- `flip` first argument is a function, two arguments afterwards are
-- arguments to method.
Prelude> :t flip
-- A function argument in a function type can be expressed using parentheses
-- to define type signature of inner method.
flip :: (a -> b -> c) -> b -> a -> c
Prelude> (-) 10 1
9
Prelude> fSub = flip (-)
Prelude> fSub 10 1
-9
Prelude>
```

- Review of how parentheses associate in type signatures:

```haskell
Prelude> :{
-- Returns last argument, no parentheses
Prelude| returnLast :: a -> b -> c -> d -> d
Prelude| returnLast _ _ _ d = d
Prelude| :}
Prelude> returnLast 0 1 2 3
3
-- Parenthesized, but with no change in behavior
Prelude> :{
Prelude| returnLast' :: a -> (b -> (c -> (d -> d)))
Prelude| returnLast' _ _ _ d = d
Prelude| :}
Prelude> returnLast' 0 1 2 3
3
-- Broken, type signature implies a single function that is the sole
-- argument to `returnBroke`.
Prelude> :{
Prelude| returnBroke :: (((a -> b) -> c) -> d) -> d
Prelude| returnBroke _ _ _ d = d
Prelude| :}

<interactive>:88:1: error:
    • Couldn't match expected type ‘d’
                  with actual type ‘p0 -> p1 -> p2 -> p2’
      ‘d’ is a rigid type variable bound by
        the type signature for:
          returnBroke :: forall a b c d. (((a -> b) -> c) -> d) -> d
        at <interactive>:87:1-42
    • The equation(s) for ‘returnBroke’ have four arguments,
      but its type ‘(((a -> b) -> c) -> d) -> d’ has only one
    • Relevant bindings include
        returnBroke :: (((a -> b) -> c) -> d) -> d
          (bound at <interactive>:88:1)
Prelude> :{
Prelude| returnAfterApply :: (a -> b) -> a -> c -> b
Prelude| returnAfterApply f a c = f a
Prelude| :}
Prelude>
```

- We parenthesize to the left so that we can refer to a separate function.

- See `employeeRank.hs`.