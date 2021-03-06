-- LibraryFunctions.hs
module LibraryFunctions where

import Data.Foldable
import Data.Monoid


-- 1)
sum' :: (Foldable t, Num a) => t a -> a
-- (FROM ANSWER KEY: https://github.com/johnchandlerburnham/hpfp)
sum' xs = foldr (+) 0 xs
-- Alternatively, with `foldMap`:
sum'' :: (Foldable t, Num a) => t a -> a
sum'' = getSum . foldMap Sum

-- 2)
-- (CORRECT BY GHCI OUTPUT)
product' :: (Foldable t, Num a) => t a -> a
product' xs = foldr (*) 1 xs

product'' :: (Foldable t, Num a) => t a -> a
product'' = getProduct . foldMap Product

-- 3)
elem' :: (Foldable t, Eq a) => a -> t a -> Bool
-- (FROM ANSWER KEY: https://github.com/johnchandlerburnham/hpfp)
elem' x xs = foldr ((||) . (== x)) False xs

-- (FROM ANSWER KEY: https://github.com/johnchandlerburnham/hpfp)
elem'' :: (Foldable t, Eq a) => a -> t a -> Bool
elem'' x xs = getAny $ foldMap (Any . (== x)) xs

-- 4)
-- minimum :: (Foldable t, Ord a) => t a -> Maybe a
-- minimum xs = foldr ((||) . (< x)) Nothing xs
--
-- (FROM ANSWER KEY: https://github.com/johnchandlerburnham/hpfp)
--
-- (PERSONAL NOTE: Answer key defines a monoid for helping implement minimum. I
-- would not have thought to done that.)
newtype Least a = Least { getLeast :: Maybe a } deriving (Eq, Ord, Show)

-- (PERSONAL NOTE: Have to implement my own Semigroup because of GHC upgrade.)
instance Ord a => Semigroup (Least a) where
    (<>) (Least Nothing) a = a
    (<>) a (Least Nothing) = a
    (<>) (Least (Just a)) (Least (Just b)) = Least (Just (min a b))

instance Ord a => Monoid (Least a) where
    mempty = Least Nothing
    mappend = (<>)

minimum' :: (Foldable t, Ord a) => t a -> Maybe a
minimum' xs = getLeast $ foldMap (Least . Just) xs

-- 5)
--
-- (CORRECT BY GHCI OUTPUT)
newtype Most a = Most { getMost :: Maybe a } deriving (Eq, Ord, Show)

instance Ord a => Semigroup (Most a) where
    (<>) (Most Nothing) a = a
    (<>) a (Most Nothing) = a
    (<>) (Most (Just a)) (Most (Just b)) = Most (Just (max a b))

instance Ord a => Monoid (Most a) where
    mempty = Most Nothing
    mappend = (<>)

maximum' :: (Foldable t, Ord a) => t a -> Maybe a
maximum' xs = getMost $ foldMap (Most . Just) xs

-- 6)
-- null' :: (Foldable t) => t a -> Bool
-- (PERSONAL NOTE: I know I should probably check whether the value is 'mempty',
-- but I'm not sure how to do that.)
--
-- (FROM ANSWER KEY: https://github.com/johnchandlerburnham/hpfp)
--
newtype Null a = Null { getNull :: Bool } deriving (Eq, Show)

instance Semigroup (Null a) where
    (<>) (Null True) (Null True) = Null True
    (<>) _ _ = Null False

instance Monoid (Null a) where
    mempty = Null True
    mappend = (<>)

null' :: (Foldable t) => t a -> Bool
null' xs = getNull $ foldMap (Null . (const False)) xs

-- 7)
-- length' :: (Foldable t) => t a -> Int
-- (PERSONAL NOTE: Try and increment by one starting at zero for xs?)
-- (INCORRECT, COMPILE TIME ERROR)
--
-- length' xs = foldr (+1) 0 xs
--
-- (FROM ANSWER KEY: https://github.com/johnchandlerburnham/hpfp)
--
newtype Long a = Long { getLong :: Int } deriving (Eq, Show)

instance Semigroup (Long a) where
    -- (PERSONAL NOTE: I'm not sure why the values are added here as 'a + b'.)
    (<>) (Long a) (Long b) = Long (a + b)

instance Monoid (Long a) where
    mempty = Long 0
    mappend = (<>)

length' :: (Foldable t) => t a -> Int
-- (PERSONAL NOTE: Not sure why this is const 1 instead of const 0)
length' xs = getLong $ foldMap (Long . (const 1)) xs

-- 8)
--
-- (PERSONAL NOTE: Going to try and replicate answer key thing of creating a
-- type and defining my own mempty and mappend)
--
-- newtype Listy a = Listy { getListy :: [a] } deriving (Eq, Show)
--
-- instance Semigroup (Listy a) where
--     (<>) (Listy a) (Listy b) = Listy (a, b)
--
-- instance Monoid (Listy a) where
--     mempty = Listy []
--     mappend = (<>)
--
-- toList' :: (Foldable t) => t a -> [a]
-- toList' xs = getListy $ foldMap (Listy . (const [])) xs
--
-- (INCORRECT, COMPILE TIME ERROR)
--
-- (FROM ANSWER KEY: https://github.com/johnchandlerburnham/hpfp)
-- (PERSONAL NOTE: I think there's something wrong with this example; I was
-- expecting [[1]], but instead I get [1]. I think that should only be something
-- I get from `concatMap`. Not sure why answer key here uses the `cons`
-- operator.)
toList' :: (Foldable t) => t a -> [a]
toList' xs = foldMap (:[]) xs

-- 9)
--
-- (FROM ANSWER KEY: https://github.com/johnchandlerburnham/hpfp)
--
fold' :: (Foldable t, Monoid m) => t m -> m
fold' xs = foldMap id xs

-- 10)
foldMap' :: (Foldable t, Monoid m) => (a -> m) -> t a -> m
-- foldMap' f xs = foldr f mempty xs
-- (INCORRECT, COMPILE TIME ERROR)
-- (FROM ANSWER KEY: https://github.com/johnchandlerburnham/hpfp)
--
foldMap' f xs = foldr ((<>) . f) mempty xs


main :: IO ()
main = do
    print $ sum' [1..5]
    print $ sum'' [1..5]

    print $ product' [1..5]
    print $ product'' [1..5]

    print $ elem' 3 [1..5]
    print $ elem'' 3 [1..5]

    print $ minimum' [1..5]

    print $ maximum' [1..5]

    print $ null' []

    print $ length' [1..5]

    print $ toList' [1]

    print $ fold' $ map Product [1..5]

    print $ foldMap' Sum [1..4]
