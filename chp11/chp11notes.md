# Chapter 11 (NEED TO REVIEW AGAIN)

- Algebraic datatypes
    - Writing your own datatypes can help you leverage Haskell's most powerful
      features: pattern matching, type checking, and type inference
    - Data type: enumeration of constructors that can have zero or more
      arguments
    - Sum types, product types, product types with record syntax, type aliases,
      `newtype`

- Data declarations review
    - Custom datatypes help you model your domain that solve your problem.

```haskell
-- Can't override native syntax `[]`, so using `:info` in order to view data
-- types.
Prelude> :i Bool
data Bool = False | True 	-- Defined at <interactive>:1:1
-- 0 1    2 3     4 5
--
-- 1: Type constructor with no arguments.
--
-- 3: Data constructor. It takes no arguments, so it is a nullary constructor.
-- Shows p in term-level code.
--
-- 4: Logical disjunction on what values can be part of that type.
Prelude> :i []
data [] a = [] | a : [a] 	-- Defined in ‘GHC.Types’
--   7      8      9
--
-- 7: Type constructor with an argument. `a` in this case is a polymorphic
-- type variable, so list argument can be different types.
--
-- 9: Data constructor that takes in two arguments: `a` and `[a]`.
```

- `Bool` is an enumeration of two possible constructors, each with zero arguments
- `[]` enumerates two possible constructors and one of them takes two arguments.

- `|`, or logical disjunction, represents a "sum type", a type with more than
  one constructor.

- Data and type constructors
    - Type constructors
        - Used at the type level, in type signatures, and typeclass declarations
          and instances
        - Static, resolve at compile time
    - Data constructors
        - Construct values at term level
    - Can make a distinction between constants and constructors.
        - Type/data constructors that don't take arguments are constants.
        - `Bool` is a constant.
        - `True` and `False` are constants.
        - They're less constructors because they're not constructing anything.
        - Sometimes, a constructor may need to be parametrized with different
          types or amounts of data.
        - Then, they become like functions that must be applied to become a
          "concrete type/value".

```haskell
Prelude> data Trivial = Trivial'
--            0         1
-- 0: Type constructor is like a constant value at the type level.
-- Otherwise called type constants.
--
-- 1: Data constructor is like constant value at the value/term/runtime
-- level (all describe the same thing).
Prelude> data UnaryTypeCon a = UnaryValueCon a
--            0                1
-- 0: UnaryTypeCon is a type constructor with one argument. Awaiting a type
-- constant to be applied to. Type-level functions exist, but aren't covered
-- here.
--
-- 1: UnaryValueCon is a data constructor with one value. Careful that
-- not all type arguments to constructors have value-level witnesses.
-- (PERSONAL NOTE: Not sure what phantom witnesses are in this case...)
Prelude>
```

- Type constructors and kinds
    - Kind signature: Type of types of types one level up.
    - Represented by `*`.
    - Something is fully applied and concrete when represented as a kind (`*`).
    - Something is waiting to be applied when it is a function (`* -> *`).

```haskell
Prelude> f = not True
Prelude> :t f
-- Of the form `*`.
f :: Bool
Prelude> f x = x > 3
Prelude> :t f
-- Of the form `* -> *`.
f :: (Ord a, Num a) => a -> Bool
-- We can query the kind signature of a type constructor using GHCi method
-- `:kind`.
Prelude> :kind Bool
Bool :: *
Prelude> :kind [Int]
[Int] :: *
Prelude> :kind []
[] :: * -> *
Prelude>
```

- Data constructors and values

```haskell
-- PugType is a type constant, that enumerates one constructor.
--
-- PugData is a constant value data constructor. Any function that requires
-- a value of type PugType, that value will always be PugData.
Prelude> data PugType = PugData
-- HuskyType is a type constructor, enumerates one constructor, taking in a
-- single parametrically polymorphic type variable as an argument.
--
-- HuskyData is a data constructor with no arguments. Type argument `a` is
-- a phantom or "has no witness". HuskyData is a constant value.
Prelude> data HuskyType a = HuskyData
-- DogueDeBordeaux is a type constructor, enumerating one constructor, with
-- one variable argument (equivalent to `a` through alpha equivalence).
--
-- The data constructor has the same name as the type constructor, but they
-- are different things. As the variable in the data constructor appears in
-- the type constructor, they are the same data.
Prelude> data DogueDeBordeaux doge = DogueDeBordeaux doge
-- We can use these definitions in constructing the following values.
--
-- We can construct `myPug` with or without casting to PugType.
Prelude> myPug = PugData
Prelude> myPug = PugData :: PugType
-- We can apply whatever concrete types or constrained / free polymorphic
-- types when casting myHusky or myOtherHusky, because the type variable
-- is a phantom variable that does not affect the data constructor.
Prelude> myHusky :: HuskyType a; myHusky = HuskyData
Prelude> myOtherHusky :: Num a => HuskyType a; myOtherHusky = HuskyData
-- We can apply a type and a matching value when constructing values of
-- type DogueDeBordeaux.
Prelude> myDoge :: DogueDeBordeaux Int; myDoge = DogueDeBordeaux 10
-- If the type and value for the type variable of DogueDeBordeaux do not
-- match, then a compile-time error occurs because the value cannot be
-- reconciled.
Prelude> badDoge :: DogueDeBordeaux String; badDoge = DogueDeBordeaux 10

<interactive>:18:62: error:
    • No instance for (Num String) arising from the literal ‘10’
    • In the first argument of ‘DogueDeBordeaux’, namely ‘10’
      In the expression: DogueDeBordeaux 10
      In an equation for ‘badDoge’: badDoge = DogueDeBordeaux 10
Prelude>
```

```haskell
-- Type signature for Doggies looks very much like a function.
Prelude> data Doggies a = Husky a | Mastiff a deriving (Eq, Show)
-- Needs to be applied to become a concrete type.
Prelude> :k Doggies
Doggies :: * -> *
-- Needs to be applied to become a concrete value.
Prelude> :t Husky
Husky :: a -> Doggies a
Prelude>
```

********** BEGIN EXERCISES: DOG TYPES **********

1. `Doggies` is a type constructor, because it is on the left side of the `=`
   sign.

2. `Doggies` is a kind that is waiting to be applied (`* -> *`).

3. `Doggies String` is a kind that has been fully applied (`*`).

4. `Husky 10` has the type of `Doggies Num a => a` (PARTIALLY CORRECT, `Num a =>
   Doggies a`).

5. `Husky (10 :: Integer)` has the type of `Doggies Integer`. (CORRECT)

6. `Mastiff "Scooby Doo"` has the type of `Doggies String`. (CORRECT)

7. `DogueDeBordeaux` is both a type constructor and a data constructor. (CORRECT
   BY ANSWER KEY: https://github.com/johnchandlerburnham/hpfp)

8. The type of `DogueDeBordeaux` should be `DogueDeBordeaux a`. (INCORRECT,
   `doge -> DogueDeBordeaux doge`.)

9. The type of `DogueDeBordeaux "doggie!"` should be `DogueDeBordeaux String`.
   (CORRECT)

********** END EXERCISES: DOG TYPES **********

- What's a type and what's data?
    - Types are checked at compile-time
    - Data is checked at run-time
    - Type constructors are before the `=` in datatype definition.
    - Data constructors are after the `=` in datatype definition.

    - When data constructors take arguments, those arguments refer to other
      types.

```haskell
data Price = Price Integer deriving (Eq, Show)
--   0       1     2
-- 0: Type constructor
-- 1: Data constructor
-- 2: Type argument
```

```haskell
data Manufacturer = Mini | Mazda | Tata deriving (Eq, Show)
--   0              1      2       3
-- 0: Type constructor
-- 1, 2, 3: Data constructors
data Airline = PapuAir | CatapultsR'Us | TakeYourChangesUnited deriving (Eq, Show)
--   0         1         2               3
-- 0: Type constructor
-- 1, 2, 3: Data constructors
```

```haskell
data Price = Price Integer deriving (Eq, Show)
data Manufacturer = Mini | Mazda | Tata deriving (Eq, Show)
data Airline = PapuAir | CatapultsR'Us | TakeYourChangesUnited deriving (Eq, Show)
-- Datatype definition where data constructors have arguments.
data Vehicle = Car Manufacturer Price | Plane Airline deriving (Eq, Show)
--   0         1   2            3       4     5
-- 0: Type constructor
-- 1, 4: Data constructors
-- 2, 3: Type arguments to data constructor `Car`
-- 5: Type argument to data constructor `Plane`
```

- Type constructors used as type arguments to another type constructor must be
  in scope in order to construct the type.

- Deriving `Show` allows data to be printed to the screen as a string.
- Deriving `Eq` is also common and enables you to use equality operations
  automatically.

- Type arguments can be types, not specific values. (e.g. `False` is invalid,
  `Bool` is valid)

********** START EXERCISES: VEHICLES **********

```haskell
myCar = Car Mini (Price 14000)
urCar = Car Mazda (Price 20000)
clownCar = Car Tata (Price 7000)
doge = Plane PapuAir
```

1. The type of `myCar` is `Car`. (INCORRECT, it is `Vehicle`.)

2. Below:

```haskell
isCar :: Vehicle -> Bool
--
-- CORRECT-ISH, NEED TO WRAP Car with parentheses since I'm doing pattern
-- matching.
--
-- isCar Car _ _ = True
isCar (Car _ _) = True
isCar _ = False

isPlane :: Vehicle -> Bool
-- Answer key has two `_`; this doesn't seem right since the `Plane` data
-- constructor has one type argument.
--
-- This may be due to 5), altering Plane to have two attributes.
--
-- (CORRECT)
isPlane (Plane _) = True
isPlane _ = False

areCars :: [Vehicle] -> [Bool]
-- This method checks whether every element is of type `Car`. Answer key
-- has better check of `any isCar`.
areCars = map . isCar
```

3. Below:

```haskell
getManu :: Vehicle -> Manufacturer
-- CORRECT BY ANSWER KEY
getManu (Car manufacturer _) = manufacturer
getManu _ = undefined
```

4. A run-time error will occur, as the incorrect data will be present and the
   attribute `Manufacturer` will not be present.

5. Below:

```haskell
-- (CORRECT)
data Vehicle = Car Manufacturer Price | Plane Airline Size deriving (Eq, Show)
```

********** END EXERCISES: VEHICLES **********

- Data constructor arities
    - arity: number of arguments a function/constructor takes.
    - nullary: 0-arity
    - unary, binary: 1-arity, 2-arity
    - nullary data constructors are constant values (witness of datatype)
    - Data constructors that take more than one argument are called products.

```haskell
-- nullary
Prelude> data Example0 = Example0 deriving (Eq, Show)
-- unary
Prelude> data Example1 = Example1 Int deriving (Eq, Show)
-- binary, product of Int and String
Prelude> data Example2 = Example2 Int String deriving (Eq, Show)
Prelude>
```

- Tuples are the canonical product type; they are anonymous products because
  they have no name.

```haskell
Prelude> data MyType = MyVal Int deriving (Eq, Show)
--            1        2     3   4         5
-- 1: Type constructor
-- 2: Data constructor
-- 3: Type argument
-- 4: Driving clause
-- 5: Typeclass instances being derived.
Prelude> :t MyVal
MyVal :: Int -> MyType
Prelude> MyVal 10
MyVal 10
-- Free equality comparison operators.
Prelude> MyVal 10 == MyVal 10
True
Prelude> MyVal 10 == MyVal 9
False
Prelude>
```

- What makes these datatypes algebraic?
    - Algebraic: We can describe the patterns of argument structures, deriving
      from type/set theory
    - Two basic operations: sum & product

- Cardinality of a datatype: number of possible values it defines
    - From 0 to infinity
    - This helps reason about programs (PERSONAL NOTE: Like generative testing
      does with Enum types instead of string types)
    - e.g. `Bool` has two types: `True` and `False`. `Bool` has cardinality 2.
    - e.g. `Int8` has minBound -127 and maxBound 128. `Int8` has cardinality
      256.

********** BEGIN EXERCISES: CARDINALITY **********

(ALL CORRECT, ANSWER KEY https://github.com/johnchandlerburnham/hpfp)

1. 1, because there is no variation allowed in the data constructor through type
   arguments.

2. 3, because there are three separate data constructors, each with no type
   arguments.

3. It should be 2 ^ 16, or 65536.

4. Below:

```haskell
Prelude> maxBound :: Int
9223372036854775807
Prelude> maxBound :: Integer

<interactive>:11:1: error:
    • No instance for (Bounded Integer)
        arising from a use of ‘maxBound’
    • In the expression: maxBound :: Integer
      In an equation for ‘it’: it = maxBound :: Integer
Prelude> minBound :: Int
-9223372036854775808
Prelude> minBound :: Integer

<interactive>:13:1: error:
    • No instance for (Bounded Integer)
        arising from a use of ‘minBound’
    • In the expression: minBound :: Integer
      In an equation for ‘it’: it = minBound :: Integer
Prelude>
```

Data type `Integer` is unbounded, so has infinite cardinality. Data type `Int`
is bounded between -9223372036854775808 and 9223372036854775807, and so has a
cardinality of 18446744073709551616.

5. 2 ^ 8 = 256. Every digit place in the binary representation of `Int8` results
   in a doubling of the cardinality.

********** END EXERCISES: CARDINALITY **********

- Simple datatypes with nullary data constructors
  - Represent one value when reasoning about cardinality.

********** BEGIN EXERCISES: FOR EXAMPLE **********

1. Below:

```haskell
Prelude> data Example = MakeExample deriving Show
-- Type of `MakeExample` is `Example`.
Prelude> :t MakeExample
MakeExample :: Example
-- Requesting the type of `Example` results in an error.
Prelude> :t Example

<interactive>:1:1: error: Data constructor not in scope: Example
Prelude>
```

2. Below:

```haskell
-- Typeclass instance `Show` is visible.
Prelude> :i Example
data Example = MakeExample 	-- Defined at <interactive>:14:1
instance [safe] Show Example -- Defined at <interactive>:14:37
Prelude>
```

3. Below:

```haskell
-- `Int` becomes a type argument that is applied to MakeExample2 data
-- constructor to create a value of type `Example2`.
Prelude> data Example2 = MakeExample2 Int deriving Show
Prelude> :t MakeExample2
MakeExample2 :: Int -> Example2
Prelude>
```

********** END EXERCISES: FOR EXAMPLE **********

- Unary constructors
    - Data is not constructed at compile-time, but wil be constructed at runtime
      from argument applied.
    - Datatypes with a unary constructor have same cardinality as type contained.
    - For cardinality, unary constructors are the identity function.

- `newtype`
    - Define a type that can only ever have a single unary data constructor.
    - `newtype` cannot be a product type, sum type, or contain nullary
      constructors.
    - `newtype` has no runtime overhead; it re-uses the representation of the
      type it contains.

```haskell
-- Unsafe; may confuse number of cows with number of goats
Prelude> tooManyGoats :: Int -> Bool; tooManyGoats n = n > 42
-- Use `newtype` to wrap `Int` as different types
Prelude> newtype Goats = Goats Int deriving (Eq, Show)
Prelude> newtype Cows = Cows Int deriving (Eq, Show)
-- Safer version of prior method sets type in type signature, resulting in a
-- compile-time error if incorrect type was passed.
Prelude> tooManyGoats' :: Goats -> Bool; tooManyGoats' (Goats n) = n > 42
-- Returns correct value
Prelude> tooManyGoats' (Goats 43)
True
-- Compile-time error
Prelude> tooManyGoats' (Cows 43)

<interactive>:8:16: error:
    • Couldn't match expected type ‘Goats’ with actual type ‘Cows’
    • In the first argument of ‘tooManyGoats'’, namely ‘(Cows 43)’
      In the expression: tooManyGoats' (Cows 43)
      In an equation for ‘it’: it = tooManyGoats' (Cows 43)
Prelude>
```

- `newtype` is similar to a "type synonym" in that representation of named type
  and single type argument are identical and no distinction between them exists
  at compile time.
  - `String` -> `[Char]` (type synonym)
  - `Goats` -> `Int` (newtype)

- `newtype` and "type synonym" is that you can define typeclass instances for
  `newtype`s on top of contained type, which is not possible for type aliases.

```haskell
-- Typeclass `TooMany`.
Prelude> class TooMany a where tooMany :: a -> Bool
-- Instance for `Int`.
Prelude> instance TooMany Int where tooMany n = n > 42
Prelude> tooMany (42 :: Int)
False
-- If not cast to type `Int`, results in a runtime exception.
Prelude> tooMany 42

<interactive>:4:1: error:
    • Ambiguous type variable ‘a0’ arising from a use of ‘tooMany’
      prevents the constraint ‘(TooMany a0)’ from being solved.
      Probable fix: use a type annotation to specify what ‘a0’ should be.
      These potential instance exist:
        instance [safe] TooMany Int -- Defined at <interactive>:2:10
    • In the expression: tooMany 42
      In an equation for ‘it’: it = tooMany 42

<interactive>:4:9: error:
    • Ambiguous type variable ‘a0’ arising from the literal ‘42’
      prevents the constraint ‘(Num a0)’ from being solved.
      Probable fix: use a type annotation to specify what ‘a0’ should be.
      These potential instances exist:
        instance Num Integer -- Defined in ‘GHC.Num’
        instance Num Double -- Defined in ‘GHC.Float’
        instance Num Float -- Defined in ‘GHC.Float’
        ...plus two others
        (use -fprint-potential-instances to see them all)
    • In the first argument of ‘tooMany’, namely ‘42’
      In the expression: tooMany 42
      In an equation for ‘it’: it = tooMany 42
-- To define a special instance of `TooMany` that has different behavior
-- from `Int`, use `newtype`.
Prelude> newtype Goats = Goats Int deriving Show
Prelude> instance TooMany Goats where tooMany (Goats n) = n > 43
-- Now, input argument is checked by `newtype`, and no direct casting to
-- `Integer` is necessary.
Prelude> tooMany (Goats 42)
False
Prelude> tooMany (Goats 43)
False
Prelude> tooMany (Goats False)

<interactive>:11:16: error:
    • Couldn't match expected type ‘Int’ with actual type ‘Bool’
    • In the first argument of ‘Goats’, namely ‘False’
      In the first argument of ‘tooMany’, namely ‘(Goats False)’
      In the expression: tooMany (Goats False)
Prelude>
```

- For user-defined typeclasses, we can use language extension called
  `GeneralizedNewTypeDeriving` in order to reuse typeclass instances.
  - `LANGUAGE` pragma (pragma: special instruction to the compiler placed in
    source code) tells compiler to process in ways beyond what standard provides
    for.

```haskell
{-# LANGUAGE GeneralizedNewTypeDeriving #-}
-- class TooMany a where ...
-- instance TooMany Int where ...

-- Now, no need to define instance TooMany for Goats; we can re-use the one
-- from `TooMany Int`.
newtype Goats = Goats Int deriving (Eq, Show, TooMany)
```

********** BEGIN EXERCISES: LOGIC GOATS **********

See `LogicGoats.hs`.

********** END EXERCISES: LOGIC GOATS **********

- Sum types
  - To calculate cardinalities of sum types, add the cardinalities of their data
    constructors.

********** BEGIN EXERCISES: PITY THE BOOL **********

1. 2 + 2 = 4 (CORRECT)

2. 256 + 2 = 258 (CORRECT). Integer overflow should occur.

********** END EXERCISES: PITY THE BOOL **********

- Product types
  - A product is like a C-like struct type, or a way to carry multiple values
    around in a single data constructor.
  - Any data constructor with 2+ type arguments is a product type.

```haskell
-- Cardinality of 3.
data QuantumBool = QuantumTrue | QuantumFalse | QuantumBoth deriving (Eq, Show)

-- Cardinality of 9 (3 * 3).
data TwoQs = MkTwoQs QuantumBool QuantumBool deriving (Eq, Show)

-- Can also write like this:
type TwoQs = (QuantumBool, QuantumBool)
```

- Record syntax
  - Product types with additional syntax

```haskell
-- Cardinality: Very large
data Person = MkPerson String Int deriving (Eq, Show)

-- sample data
jm = MkPerson "julie" 108
ca = MkPerson "chris" 16

-- This method will return the `String` attribute from the data.
name :: Person -> String
name (MkPerson s _) = s

-- Record syntax, with named accessors.
--
-- name :: Person -> String
-- age :: Person -> Int
-- name jm = "julie" (If `jm` was converted from MkPerson to Person)
-- age jm = 108 (If `jm` was converted from MkPerson to Person)
data Person =
  Person { name :: String,
         , age :: Int }
         deriving (Eq, Show)
```

- Normal form
  - Distributive property `2 * (3 + 4) = 2 * 3 + 2 * 4`
  - In normal arithmetic, normal form is when expression is reduced to final
    result
  - If you want to represent set cardinality, sum of products expression is the
    normal form, since there's no computation to perform
    - (PERSONAL NOTE: I don't understand this point)
  - True of Haskell's type system. Product types distribute over sum types.

```haskell
-- Two types with nullary data constructors.
-- This enables us to factor out book types from `Bool` (which cannot be used
-- as you cannot declare a data constructor to be a concrete value)
data Fiction = Fiction deriving Show
data Nonfiction = Nonfiction deriving Show

-- Sum type takes Fiction and Nonfiction types as arguments.
--
-- It is the type constructors that are passed to `Fictionbook` and
-- `NonfictionBook`.
data BookType = FictionBook Fiction | NonfictionBook Nonfiction deriving Show

-- `AuthorName` is type synonym for `String`.
type AuthorName = String
data Author = Author (AuthorName, BookType)

-- The above can be deconstructed to:
--
-- As products distribute over sums.
data Author =
  Fiction AuthorName
  | Nonfiction AuthorName deriving (Eq, Show)

-- `Expr` type used in type systems papers
--
-- This is normal form because it's a sum of products expression
data Expr =
  Number Int
  | Add Expr Expr
  | Minus Expr
  | Mult Expr Expr
  | Divide Expr Expr

-- Another way to represent sum-of-products form would be to represent
-- products with tuples and sums with `Either`.
--
-- Commonly used when you're writing functions or folds over
-- datatype representations.
type Number = Int
type Add = (Expr, Expr)
type Minus = Expr
type Mult = (Expr, Expr)
type Divide = (Expr, Expr)

type Expr =
  Either Number
    (Either Add
      (Either Minus
        (Either Mult Divide)))
```

********** BEGIN EXERCISES: HOW DOES YOUR GARDEN GROW? **********

(CORRECT I THINK, ANSWER KEY https://github.com/johnchandlerburnham/hpfp)

1. Below:

```haskell
data FlowerType = Gardenia | Daisy | Rose | Lilac deriving Show
type Gardener = String

data Garden = Garden Gardener FlowerType deriving Show

-- Sum-of-products representation of `Garden`
--
-- A type synonym cannot have any typeclass or other deviations from base
-- type, so I think it is safe to have Gardener remain instead of String.
--
-- Also I think order matters in data constructor (otherwise pattern
-- matching would fail to convert between the two definitions, given how
-- accessors are not named in either case, so I don't know why the answer
-- key reversed them)
data Garden =
  Gardener Gardenia
  | Gardener Daisy
  | Gardener Rose
  | Gardener Lilac deriving Show
```

********** END EXERCISES: HOW DOES YOUR GARDEN GROW? **********

- Constructing and deconstructing values
  - Since data is immutable in Haskell, values carry with them information on
    how they were created.

```haskell
-- Create some datatypes.
data GuessWhat = Chickenbutt deriving (Eq, Show)
data Id a = MkId a deriving (Eq, Show)
data Product a b = Product a b deriving (Eq, Show)
data Sum a b = First a | Second b deriving (Eq, Show)
data RecordProduct a b = RecordProduct { pfirst :: a, psecond :: b } deriving (Eq, Show)
```

- Sum and product

```haskell
-- Ideally you avoid having nestable sum and product types...this is mostly
-- for demonstration purposes.
data Product a b = Product a b deriving (Eq, Show)
data Sum a b = First a | Second b deriving (Eq, Show)

newtype NumCow = NumCow Int deriving (Eq, Show)
newtype NumPig = NumPig Int deriving (Eq, Show)

-- Farmhouse and Farmhouse' are the same
data Farmhouse = Farmhouse NumCow NumPig deriving (Eq, Show)
type Farmhouse' = Product NumCow NumPig

newtype NumSheep = NumSheep Int deriving (Eq, Show)

-- BigFarmhouse and BigFarmhouse' are the same
data BigFarmhouse = BigFarmhouse NumCow NumPig NumSheep deriving (Eq, Show)
type BigFarmhouse' = Product NumCow (Product NumPig NumSheep)

type Name = String
type Age = Int
type LovesMud = Bool
-- Fun fact: Sheep can produce between 2 and 30 pounds of wool a year!
type PoundsOfWool = Int

data CowInfo = CowInfo Name Age deriving (Eq, Show)
data PigInfo = PigInfo Name Age LovesMud deriving (Eq, Show)
data SheepInfo = SheepInfo Name Age PoundsOfWool deriving (Eq, Show)

-- Animal and Animal' are the same
data Animal = Cow CowInfo | Pig PigInfo | Sheep SheepInfo deriving (Eq, Show)
type Animal' = Sum CowInfo (Sum PigInfo SheepInfo)
```

- You can use `First` and `Second` to pattern match on data constructors of
  `Sum`.

```haskell
-- With context from prior computations
Prelude> bess' = (CowInfo "Bess" 4)
Prelude> bess = First bess' :: Animal'
Prelude>
Prelude> let e' = Second (SheepInfo "Elmer" 5 5)
Prelude> elmer = Second e' :: Animal'
Prelude>
-- Making a mistake
Prelude> let elmo' = Second (SheepInfo "Elmo" 5 5)
Prelude> elmo = First elmo' :: Animal'

<interactive>:44:8: error:
    • Couldn't match type ‘Sum a0 SheepInfo’ with ‘CowInfo’
      Expected type: Animal'
        Actual type: Sum (Sum a0 SheepInfo) (Sum PigInfo SheepInfo)
    • In the expression: First elmo' :: Animal'
      In an equation for ‘elmo’: elmo = First elmo' :: Animal'
Prelude>
```

- Constructing values

```haskell
-- Trivial types like this sometimes used to signal discrete concepts.
trivialValue :: GuessWhat
trivialValue = Chickenbutt

idInt :: Id Integer
idInt = MkId 10

-- type synonyms for clarity.
--
-- Try to avoid using type synonyms with unstructured data like text/binary.
type Awesome = Bool
type Name = String

person :: Product Name Awesome
person = Product "Simon" True

data Twitter = Twitter deriving (Eq, Show)
data AskFm = AskFm deriving (Eq, Show)

-- data socialNetwork = Twitter | AskFm deriving (Show, Eq)
socialNetwork :: Sum Twitter AskFm
socialNetwork = First Twitter
```

********** BEGIN EXERCISES: PROGRAMMERS **********

See `Programmer.hs`.

********** END EXERCISES: PROGRAMMERS **********

- Accidental bottoms from records

```haskell
-- (Given context of `Programmer.hs`)
-- Prelude> :l Programmer.hs
-- [1 of 1] Compiling Programmer       ( Programmer.hs, interpreted )
-- Ok, one module loaded.

-- (Partial definition of data value, not defining lang)
-- *Programmer> let partialAf = Programmer {os = GnuPlusLinux}

-- <interactive>:2:17: warning: [-Wmissing-fields]
--     • Fields of ‘Programmer’ not initialised: lang
--     • In the expression: Programmer {os = GnuPlusLinux}
--       In an equation for ‘partialAf’:
--           partialAf = Programmer {os = GnuPlusLinux}

-- (Then attempting to "show" the value results in a runtime exception)
-- *Programmer> partialAf
-- Programmer {os = GnuPlusLinux, lang = *** Exception: <interactive>:2:17-46: Missing field in record construction lang

-- *Programmer>
```

- Either define the whole record at once, or not at all. If you think you need
  to do this, your code needs to be refactored.
  - (PERSONAL NOTE: Huh, no sane defaults applied by default..)
  - Partial application of the data constructor can handle this.

```haskell
data ThereYet = There Float Int Bool deriving (Eq, Show)
nope = There

-- kind of like a builder pattern
notYet :: Int -> Bool -> ThereYet
notYet = nope 25.5

notQuite :: Bool -> ThereYet
notQuite = notYet 10

yuss :: ThereYet
yuss = notQuite False
```

- Deconstructing values

```haskell
newtype Name = Name String deriving Show
newtype Acres = Acres Int deriving Show

-- FarmerType is a Sum
data FarmerType = DairyFarmer | WheatFarmer | SoybeanFarmer deriving Show

-- Farmer is a plain ole product of Name, Acres, and FarmerType
data Farmer = Farmer Name Acres FarmerType deriving Show

-- Method to unpack data inside constructor
--
-- Prelude> farmer = Farmer (Name "Hector") (Acres 10) DairyFarmer
-- Prelude> isDairyFarmer farmer
-- True
-- Prelude>
--
isDairyFarmer :: Farmer -> Bool
isDairyFarmer (Farmer _ _ DairyFarmer) = True
isDairyFarmer _ = False

-- Another way of defining Farmer and isDairyFarmer, this time with
-- named accessors.
data FarmerRec = FarmerRec { name :: Name, acres :: Acres, farmerType :: FarmerType } deriving Show
isDairyFarmerRec :: FarmerRec -> Bool
isDairyFarmerRec farmer =
  case farmerType farmer of
    DairyFarmer -> True
    _ -> False
```

- Accidental bottoms from records
  - You can easily propagate bottoms through record types (not a good idea)

```haskell
-- Don't do this
--
-- Instead of Null, there is datatype Maybe. Also consider case where you used
-- a named successor but need to use Null anyways
data Automobile = Null | Car { make :: String, model :: String, year :: Integer} deriving (Eq, Show)

-- To fix this:
-- Whenever you have a product type that uses record accessors, keep it
-- separate from any sum type that is wrapping it.
--
-- This way, the type system and typechecker can catch it.
data Car = Car { make :: String, model :: String, year :: Integer } deriving (Eq, Show)
data Automobile = Null | Automobile Car deriving (Eq, Show)
```

- Function type is exponential
  - Given a function a -> b, cardinality exponentiates by b ^ a.
  - e.g. `Bool -> Bool` -> `2 ^ 2`, and `Bool -> Bool -> Bool` is `2 ^ 2 ^ 2`.
  - `a -> b -> c` is `(c ^ b) ^ a`, which is also equal to `c ^ (b * a)`.

********** BEGIN EXERCISES: THE QUAD **********

(CORRECT, all except 1. matches the answer key, I don't think the answer key is
correct for 1.)

1. 4 (four nullary data constructors)

2. 16 (4 * 4, product type)

3. 256 (4 ^ 4, function)

4. 8 (2 * 2 * 2, product type)

5. 16 (2 ^ 2 ^ 2, function)

6. 65536 (4 ^ 4 ^ 2, function)

********** END EXERCISES: THE QUAD **********

- Higher-kinded datatypes
  - Default kind seen before is `*`.
  - Kinds are not types until fully applied
  - `* -> *` and so forth are not kinds until fully applied; these are
    higher-kinded types.
  - Lists are higher-kinded datatypes in Haskell.

```haskell
Prelude> :{
Prelude| data Silly a b c d =
Prelude|   MkSilly a b c d deriving Show
Prelude| :}
Prelude> :kind Silly
Silly :: * -> * -> * -> * -> *
Prelude> :kind Silly Int
Silly Int :: * -> * -> * -> *
Prelude> :kind Silly Int String
Silly Int String :: * -> * -> *
Prelude> :kind Silly Int String Bool
Silly Int String Bool :: * -> *
Prelude> :kind Silly Int String Bool String
Silly Int String Bool String :: *
Prelude> :kind (,,,,)
(,,,,) :: * -> * -> * -> * -> * -> *
Prelude> :kind (Int, String, Bool, String)
(Int, String, Bool, String) :: *
Prelude>
```

- By not constraining the type (leaving it higher-kinded), the type can be
  passed to a method that will enforce a constraint when needed, at
  compile-time.

- Lists are polymorphic
  - Can contain values of any type.
  - Don't have the type until the type argument is fully applied.

- If an operator has a non-alphanumeric name, it's infix by default.

- Binary tree
  - See `BinaryTree.hs`.

********** BEGIN CHAPTER EXERCISES **********

Multiple choice (ALL CORRECT BY ANSWER KEY)

1. a)
2. c)
3. b)
4. c)

Ciphers

See `Ciphers.hs`.

As-patterns

See `AsPatterns.hs`.

Language exercises

See `LanguageExercises.hs`.

Phone exercise

See `Phone.hs`.

Hutton's Razor

See `HuttonsRazor.hs`.

********** END CHAPTER EXERCISES **********
