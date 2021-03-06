-- FuncInstances.hs
module FuncInstances where

import Test.QuickCheck
-- For `Data.Fun`
import Test.QuickCheck.Function

functorIdentity :: (Functor f, Eq (f a)) => f a -> Bool
functorIdentity f = fmap id f == f

functorCompose :: (Eq (f c), Functor f) => (a -> b)-> (b -> c) -> f a -> Bool
functorCompose f g x = (fmap g (fmap f x)) == (fmap (g . f) x)

-- (FROM ANSWER KEY: https://github.com/johnchandlerburnham/hpfp)
type IntToInt = Fun Int Int

-- Usage for quickCheck functions.
functorCompose' :: (Eq (f c), Functor f) => Fun a b -> Fun b c -> f a -> Bool
functorCompose' (Fun _ f) (Fun _ g) x = (fmap g (fmap f x)) == (fmap (g . f) x)


-- 1)
newtype Identity a = Identity a deriving (Eq, Show)
-- (PERSONAL NOTE: Not sure how to start off..)
--
-- (FROM ANSWER KEY: https://github.com/johnchandlerburnham/hpfp)
--
instance Arbitrary a => Arbitrary (Identity a) where
    arbitrary = do
    a' <- arbitrary
    return (Identity a')

instance Functor Identity where
    fmap f (Identity a) = Identity (f a)

-- 2)
data Pair a = Pair a a deriving (Eq, Show)

-- (PERSONAL NOTE: Just because type constructor for Pair has the same type
-- arguments, doesn't mean that arbitrary declaration can have the same
-- reference (since it is a data constructor)).
--
-- (INCORRECT, GHC COMPILE ERROR)
--
-- instance Arbitrary a => Arbitrary (Pair a b) where
--     arbitrary = do
--         a' <- arbitrary
--         b' <- arbitrary
--         return (Pair a' b')
--
-- (FROM ANSWER KEY: https://github.com/johnchandlerburnham/hpfp)
instance Arbitrary a => Arbitrary (Pair a) where
    arbitrary = do
        a <- arbitrary
        a' <- arbitrary
        return (Pair a a')

-- (INCORRECT, GHC COMPILE ERROR)
--
-- instance Functor Pair where
--     fmap f (Pair a a) = Pair (f a) (f a)
--
-- (CORRECT BY GHCI OUTPUT AND CHECKING ANSWER KEY)
--
instance Functor Pair where
    fmap f (Pair a a') = Pair (f a) (f a')

-- 3)
data Two a b = Two a b deriving (Eq, Show)

-- (PERSONAL NOTE: Not sure whether there should be two arbitrary declarations,
-- one holding 'a' constant and one holding 'b' constant, in order to ensure
-- kind-ness of arbitrary functor check) (I'm not sure how multiple functor
-- declarations would work though; how would you know which one to choose? Tuple
-- just passes the first argument on through instead of having multiple
-- functors, so I think it should be fine)
--
-- (CORRECT BY GHCI OUTPUT AND CHECKING ANSWER KEY)
--
instance (Arbitrary a, Arbitrary b) => Arbitrary (Two a b) where
    arbitrary = do
        a' <- arbitrary
        b' <- arbitrary
        return (Two a' b')

instance Functor (Two a) where
    fmap f (Two a b) = Two a (f b)

-- 4)
data Three a b c = Three a b c deriving (Eq, Show)

instance (Arbitrary a, Arbitrary b, Arbitrary c) => Arbitrary (Three a b c) where
    arbitrary = do
        a' <- arbitrary
        b' <- arbitrary
        c' <- arbitrary
        return (Three a' b' c')

-- (CORRECT BY GHCI OUTPUT)
instance Functor (Three a b) where
    fmap f (Three a b c) = Three a b (f c)

-- 5)
data Three' a b = Three' a b b deriving (Eq, Show)

-- (PERSONAL NOTE: Not sure how to manage the kind-ness of Three'; should it
-- should "Three a" or "Three a b"?) (When it is "Three a b" I get a
-- compile-time type matching error. Not sure whether it is an indication of
-- something else wrong with the program.) (Yeah I'm really stuck.)
--
-- (FROM ANSWER KEY: https://github.com/johnchandlerburnham/hpfp)
instance (Arbitrary a, Arbitrary b) => Arbitrary (Three' a b) where
    arbitrary = do
        a' <- arbitrary
        b <- arbitrary
        b' <- arbitrary
        -- (PERSONAL NOTE: Error I was getting with type matching error was
        -- because I was parenthesizing the answer wrong. It is not "Three' (a'
        -- b b')" nor "Three' a' b b'", but "(Three' a' b b')".)
        return (Three' a' b b')

instance Functor (Three' a) where
    -- (PERSONAL NOTE: Not exactly sure why GHC is giving 'conflicting
    -- definitions for 'b')
    --
    -- fmap f (Three' a b b) = Three' a (f b) (f b)
    --
    fmap f (Three' a b b') = Three' a (f b) (f b')

-- 6)
data Four a b c d = Four a b c d deriving (Eq, Show)

instance (Arbitrary a, Arbitrary b, Arbitrary c, Arbitrary d) => Arbitrary (Four a b c d) where
    arbitrary = do
        a' <- arbitrary
        b' <- arbitrary
        c' <- arbitrary
        d' <- arbitrary
        return (Four a' b' c' d')

-- (CORRECT BY GHCI OUTPUT AND CHECKING ANSWER KEY)
instance Functor (Four a b c) where
    fmap f (Four a b c d) = Four a b c (f d)

-- 7)
data Four' a b = Four' a a a b deriving (Eq, Show)

-- (PERSONAL NOTE: Not sure what the data constructor should be for "Four'".
-- "Four' a b" doesn't work, "Four' a a b" doesn't work, "Four' a a a" doesn't
-- work, "Four' a a a b" doesn't work.)
--
-- (PERSONAL NOTE: Looked at answer key, and it has "Four' a b". At this point,
-- I have only defined the arbitrary instance, and not the functor nor the
-- quickCheck declarations. Not sure why having just the arbitrary instance
-- would fail to compile. Everything else matches.)
--
-- (PERSONAL NOTE: My God, it's because I had "Four' a, a', a'', b" instead of
-- "Four' a a' a'' b". I had commas!!)
instance (Arbitrary a, Arbitrary b) => Arbitrary (Four' a b) where
    arbitrary = do
        a <- arbitrary
        a' <- arbitrary
        a'' <- arbitrary
        b <- arbitrary
        return (Four' a a' a'' b)

-- (CORRECT BY CHECKING ANSWER KEY)
instance Functor (Four' a) where
    fmap f (Four' a a' a'' b) = Four' a a' a'' (f b)

-- 8)
--
-- (You cannot implement a functor for this data type, because the kindness (*)
-- is below that of a functor (* -> *), and therefore there is nothing you can
-- do in order to transform the kindness by partially applying a type argument.)
data Trivial = Trivial


main :: IO ()
main = do
    -- (FROM ANSWER KEY: https://github.com/johnchandlerburnham/hpfp)
    quickCheck (functorIdentity :: (Identity Int) -> Bool)
    quickCheck (functorCompose' :: IntToInt -> IntToInt -> (Identity Int) -> Bool)

    -- (PERSONAL NOTE: Not 'Pair Int Int', because it would not have the proper
    -- kind-ness for a functor).
    quickCheck (functorIdentity :: (Pair Int) -> Bool)
    quickCheck (functorCompose' :: IntToInt -> IntToInt -> (Pair Int) -> Bool)

    quickCheck (functorIdentity :: (Two Int Int) -> Bool)
    quickCheck (functorCompose' :: IntToInt -> IntToInt -> (Two Int Int) -> Bool)

    quickCheck (functorIdentity :: (Three Int Int Int) -> Bool)
    quickCheck (functorCompose' :: IntToInt -> IntToInt -> (Three Int Int Int) -> Bool)

    quickCheck (functorIdentity :: (Three' Int Int) -> Bool)
    quickCheck (functorCompose' :: IntToInt -> IntToInt -> (Three' Int Int) -> Bool)

    quickCheck (functorIdentity :: (Four Int Int Int Int) -> Bool)
    quickCheck (functorCompose' :: IntToInt -> IntToInt -> (Four Int Int Int Int) -> Bool)

    -- (CORRECT BY CHECKING ANSWER KEY)
    quickCheck (functorIdentity :: (Four' Int Int) -> Bool)
    quickCheck (functorCompose' :: IntToInt -> IntToInt -> (Four' Int Int) -> Bool)
