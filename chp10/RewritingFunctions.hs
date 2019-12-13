-- RewritingFunctions.hs
module RewritingFunctions where

-- direct recursion, not using (&&)
myAnd :: [Bool] -> Bool
myAnd [] = True
myAnd (x : xs) =
    if x == False
    then False
    else myAnd xs

-- direct recursion, using (&&)
myAnd' :: [Bool] -> Bool
myAnd' [] = True
myAnd' (x : xs) = x && myAnd' xs

-- fold, not pointfree
myAnd'' :: [Bool] -> Bool
myAnd'' = foldr (\a b -> if a == False then False else b) True

-- fold, both myAnd and the folding function are pointfree now
myAnd''' :: [Bool] -> Bool
myAnd''' = foldr (&&) True


-- 1)
--
-- (CORRECT BY GHCI OUTPUT)
myOr :: [Bool] -> Bool
myOr = foldr (||) False

-- 2)
--
-- (INCORRECT, COMPILE-TIME ERROR)
myAny :: (a -> Bool) -> [a] -> Bool
-- myAny f a = foldr f False a
--
-- (PERSONAL NOTE: This is where my brain is starting to melt)
myAny f x = foldl check False x where
    check x y = x || f y

-- 3)
--
-- (CORRECT BY GHCI OUTPUT)
myElem :: Eq a => a -> [a] -> Bool
myElem a b = myAny (\x -> x == a) b

-- (I basically just copied method `myAny` and hardcoded the lambda in place of
-- the function.)
myElem' :: Eq a => a -> [a] -> Bool
myElem' a b = foldl check False b where
    check x y = x || (\x -> x == a) y
-- Another way to write this would be:
-- myElem x xs = myAny ((==) x) xs

-- 4)
myReverse :: [a] -> [a]
myReverse = undefined

-- 5)
myMap :: (a -> b) -> [a] -> [b]
myMap = undefined

-- 6)
myFilter :: (a -> Bool) -> [a] -> [a]
myFilter = undefined

-- 7)
squish :: [[a]] -> [a]
squish = undefined

-- 8)
squishMap :: (a -> [b]) -> [a] -> [b]
squishMap = undefined

-- 9)
squishAgain :: [[a]] -> [a]
squishAgain = undefined

-- 10)
myMaximumBy :: (a -> a -> Ordering) -> [a] -> a
myMaximumBy = undefined

-- 11)
myMinimumBy :: (a -> a -> Ordering) -> [a] -> a
myMinimumBy = undefined


main :: IO ()
main = do
    -- 1)
    print $ myOr [True, False, True]
    print $ myOr [False]

    -- 2)
    print $ myAny even [1, 3, 5]
    print $ myAny odd [1, 3, 5]

    -- 3)
    print $ myElem 1 [1..10]
    print $ myElem 1 [2..10]

    print $ myElem' 1 [1..10]
    print $ myElem' 1 [2..10]
