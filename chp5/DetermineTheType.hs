{-# LANGUAGE NoMonomorphismRestriction #-}

module DetermineTheType where

-- simple example
example = 1

-- 1a) (Expected: `Num a => a`, 54) (CORRECT)
_1a = (* 9) 6
-- 1b) (Expected: `(Num a => a, [Char])`, (0, "doge")) (PARTIALLY CORRECT, `Num a => (a, [Char])`)
_1b = head [(0,"doge"),(1,"kitteh")]
-- 1c) (Expected: `(Integer, [Char])`, (0, "doge")) (CORRECT)
_1c = head [(0 :: Integer, "doge"),(1, "kitteh")]
-- 1d) (Expected: Bool, False) (CORRECT)
_1d = if False then True else False
-- 1e) (Expected: Int, 5) (CORRECT)
_1e = length [1, 2, 3, 4, 5]
-- 1f) (Expected: Bool, False) (CORRECT)
_1f = (length [1, 2, 3, 4]) > (length "TACOCAT")

-- 2 (Num a => a) (CORRECT)
_2x = 5
_2y = _2x + 5
_2w = _2y * 10

-- 3 (Num a => a -> a) (CORRECT)
_3x = 5
_3y = _3x + 5
_3z _3y = _3y * 10

-- 4 (Fractional a => a) (CORRECT)
_4x = 5
_4y = _4x + 5
_4f = 4 / _4y

-- 5 ([Char]) (CORRECT)
_5x = "Julie"
_5y = " <3 "
_5z = "Haskell"
_5f = _5x ++ _5y ++ _5z
