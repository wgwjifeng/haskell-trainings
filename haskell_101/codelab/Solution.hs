-- Copyright 2019 Google LLC
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     https://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.



{-

Welcome to the Haskell 101 codelab!

To run this file, make sure you have the haskell platform, and simply:
$ make
$ ./codelab

You can also load this file in ghci:

$ ghci
> :l Codelab
> :l Main
> main

It will fail hilariously (or ridiculously, depending on your sense of
humour), because you're supposed to write some of the code! You have to
replace and code everything that is named "codelab".

Our goal, here, is to implement some of the builtin functions in the
language, as a way to get familiar with the type system.

Good luck and, most importantly, have fun!

-}





{- #####################################################################
   SECTION 0: setting up the codelab.

   Nothing to see here, please go directly to section 1!

   This section simply define the "codelab" alias that we'll use
   everywhere in the code and still have it compile and does all the
   necessary boilerplate: imports, compiler options, that kind of stuff.
-}

{-# OPTIONS_GHC -fno-warn-unused-imports #-}
{-# OPTIONS_GHC -fno-warn-unused-matches #-}
{-# OPTIONS_GHC -fno-warn-unused-binds   #-}
{-# OPTIONS_GHC -fno-warn-type-defaults  #-}

module Solution where

import Control.Monad        (void)
import Data.Maybe           (isJust)
import Text.Read            (readMaybe)
import Prelude       hiding (null, head, tail, length, and, or, (++),
                             map, filter, foldr, foldl, gcd)

codelab :: a
codelab = error "SOMETHING IS NOT IMPLEMENTED!"





{- #####################################################################
   SECTION 1: number manipulation

   As we have not looked at any complex data structures yet, so the
   only thing we have for now are numbers.
-}

add :: Int -> Int -> Int
add x y = x + y

subtract :: Int -> Int -> Int
subtract x y = x - y

double :: Int -> Int
double x = 2 * x

multiply :: Int -> Int -> Int
multiply x y = x * y

divide :: Int -> Int -> Double
divide x y = fromIntegral x / fromIntegral y

factorial :: Integer -> Integer
factorial n = if n <= 1
              then 1
              else n * factorial (n-1)

gcd :: Int -> Int -> Int
gcd a b
  | a == b = a
  | a > b = gcd (a - b) b
  | otherwise = gcd a (b - a)





{- #####################################################################
   SECTION 2: simple pattern matching

   Not that we can defined simple data structures, let's try using them.
-}

type Point = (Int, Int)

-- Do not forget about Hoogle, should you need a new function.

pointDistance :: Point -> Point -> Double
pointDistance (x1, y1) (x2, y2) =
  sqrt $ fromIntegral $ (x1 - x2) ^ 2 + (y1 - y2) ^ 2

data Minutes = Minutes Int

hours :: Minutes -> Int
hours (Minutes m) = m `div` 60

timeDistance :: Minutes -> Minutes -> Minutes
timeDistance (Minutes m1) (Minutes m2) = Minutes (abs $ m2 - m1)



{- #####################################################################
   SECTION 3: deconstructing lists

   The default list is ubiquitous in the Prelude; the default String
   type is but a type alias to [Char] after all. Though they have
   limitations, they're always useful.

   As a reminder, a list is either:
     * []     the empty list
     * (x:xs) a cell containing the value x and followed by the list xs
-}


-- null tells you whether a list is empty or not

null :: [a] -> Bool
null [] = True
null _  = False


-- head returns the first element of the list
-- if the list is empty, it panics: this function is partial

head :: [a] -> a
head []    = error "head: empty list"
head (x:_) = x


-- tail returns everything but the first element
-- if the list is empty it panics

tail :: [a] -> [a]
tail []     = error "tail: empty list"
tail (_:xs) = xs





{- #####################################################################
   SECTION 4: recursion (c.f. SECTION 4)

   There is no loop in Haskell, so to go through a list, we have to use
   recursion. Here are a few more common functions for you to
   reimplement!
-}


-- do you remember it from the slides?

length :: [a] -> Int
length []     = 0
length (_:xs) = 1 + length xs
-- length = foldl (\a _ -> a + 1) 0


-- and returns True if all the boolean values in the list are True
-- what do you think it returns for an empty list?

and :: [Bool] -> Bool
and []     = True
and (x:xs) = x && and xs
-- and = foldl (&&) True

-- or returns True if at least one value in the list is True
-- what do you think it returns for an empty list?

or :: [Bool] -> Bool
or []     = False
or (x:xs) = x || or xs
-- or = foldl (||) False


-- (++) is the concatenation operator
-- to concatenate two linked lists you have to chain the second one
-- at the end of the first one

(++) :: [a] -> [a] -> [a]
[]     ++ l2 = l2
(l:l1) ++ l2 = l : (l1 ++ l2)
-- l1 ++ l2 = foldr (:) l2 l1




{- #####################################################################
   SECTION 5: abstractions

   Have you noticed that we keep using the same pattern?
   If the list is empty we return a specific value.
   If it is not, we call a function to combine the element with the
   result of the recursive calls.

   This is Haskell: if there is a pattern, it can (must) be abstracted!
   Fortunately, some useful functions are here for us.

   To understand the difference between foldr and foldl, remember that
   the last letter indicates if the "reduction" function is left
   associative or right associative: foldr goes from right to left,
   foldl goes from left to right.

   foldl :: (a -> x -> a) -> a -> [x] -> a
   foldr :: (x -> a -> a) -> a -> [x] -> a
   foldl (-) 0 [1,2,3,4]   ==   (((0 - 1) - 2) - 3) - 4   ==   -10
   foldr (-) 0 [1,2,3,4]   ==   1 - (2 - (3 - (4 - 0)))   ==    -2
-}


-- you probably remember this one?
-- nothing extraordinary here

map :: (a -> b) -> [a] -> [b]
map _ []     = []
map f (a:as) = f a : map f as


-- same thing here for filter, except that we use it to introduce a new
-- syntax: those | are called guards; they let you specify different
-- implementations of your function depending on some Boolean
-- value. "otherwise" is not a keyword but simply a constant whose
-- value is True! Try to evaluate "otherwise" in GHCI.
--
-- Simple example of guards usage:
--   abs :: Int -> Int
--   abs x
--     | x < 0     = -x
--     | otherwise =  x

filter :: (a -> Bool) -> [a] -> [a]
filter _ [] = []
filter f (x:xs)
  | f x       = x : filter f xs
  | otherwise =     filter f xs


-- foldl
-- foldl (-) 0 [1,2,3,4]   ==   (((0 - 1) - 2) - 3) - 4   ==   -10

foldl :: (a -> x -> a) -> a -> [x] -> a
foldl _ a []     = a
foldl f a (x:xs) = foldl f (a `f` x) xs


-- foldr
-- foldr (-) 0 [1,2,3,4]   ==   1 - (2 - (3 - (4 - 0)))   ==    -2

foldr :: (x -> a -> a) -> a -> [x] -> a
foldr _ a []     = a
foldr f a (x:xs) = x `f` foldr f a xs





{- #####################################################################
   BONUS STAGE!

   For fun, you can try reimplementing all the functions in section 4
   with foldr or foldl! For length, remember that the syntax for a
   lambda function is (\arg1 arg2 -> value).

   You can replace your previous implementation if you want. Otherwise,
   you can add new functions (such as andF, orF), and test them by
   loading your file in GHCI:

   $ ghci
   > :load Codelab
   > and  []
   > andF []

   To go a bit further, you can also try QuickCheck:

   > import Test.QuickCheck
   > quickCheck $ \anyList -> and anyList == andF anyList

   QuickCheck automatically generates tests based on the types
   expected (here, list of boolean values).

   It is also worth noting that there is a special syntax for list
   comprehension in Haskell, which is at a first glance quite similar
   to the syntax of Python's list comprehension

   Python:  [transform(value) for value in container if test(value)]
   Haskell: [transform value  |   value <- container ,  test value ]

   This allows you to succinctly write your map / filters.
-}





{- #####################################################################
   SECTION 6: am I being indecisive? ....hmmmm Maybe?

   Partial functions are bad. Null pointers are a billion dollar
   mistake. Sometimes, what we just want is to have an optional value,
   a value that is either here or not, but with type safety.

   Remember Maybe? If not, here's the definition:

   data Maybe a = Nothing | Just a
-}


-- if we were to fix the "head" function, how could we do that?

safeHead :: [a] -> Maybe a
safeHead []    = Nothing
safeHead (x:_) = Just x


-- isNothing should not need an explanation by now!

isNothing :: Maybe a -> Bool
isNothing Nothing  = True
isNothing (Just _) = False


-- the fromMaybe function is your way out of a Maybe value
-- it takes a default value to use in case our Maybe value is Nothing

fromMaybe :: a -> Maybe a -> a
fromMaybe a Nothing  = a
fromMaybe _ (Just a) = a


-- the maybe function is an extended version of fromMaybe
-- can you guess what it is supposed to do?
-- ...doesn't it kinda look like fold?

maybe :: b -> (a -> b) -> Maybe a -> b
maybe b _ Nothing  = b
maybe _ f (Just a) = f a





{- #####################################################################
   PARTING WORDS

   Have you noticed that we pattern match with Maybe quite like we do
   with lists? You haven't seen Either yet, but spoilers: the pattern
   matching looks quite the same.

   Could we therefore define an equivalent of map for Maybe? For Either?
   But how could we write a function with the same name for different
   types? Will we end up needing some kind of *shivers* interface?

   Stay tuned for Haskell 102! :)

   (If you want more, head below for a bonus section!)
-}





{- #####################################################################
   BONUS SECTION: let's play a game.

   This sections goes a bit further and is optional.

   In it, we implement a small (and, arguably, not very interesting)
   game: Rock Paper Scissors! You don't have to write a lot of code in
   this section; simply take the time to read the code, and fill in the
   few blanks. You'll encounter quite a few functions you haven't seen
   before, and some new weird syntax: if you import this file in GHCI,
   you can easily inspect the type of any function with :t.

   To play a game, simply type "play" in GHCI!
   Feel free to try to modify the code and tweak it as you wish.
-}


-- some simple types for our game
-- ignore the "deriving" part (or don't, I'm a comment, not a cop)

data Hand = Rock | Paper | Scissors deriving (Show, Read, Eq)
type Score = (Int, Int)


-- winsOver tells you if a hand wins over another one
-- it introduces a nifty trick: any binary function can be used in an
-- infix way if surrounded by backquotes

winsOver :: Hand -> Hand -> Bool
Rock     `winsOver` Scissors = True
Paper    `winsOver` Rock     = True
Scissors `winsOver` Paper    = True
_        `winsOver` _        = False


-- computeScore... computes the score!
-- remember those | guards?

computeScore :: Hand -> Hand -> Score
computeScore h1 h2
  | h1 `winsOver` h2 = (1, 0)
  | h2 `winsOver` h1 = (0, 1)
  | otherwise        = (0, 0)


-- combine... combines!
-- remember pattern matching?

combine :: Score -> Score -> Score
combine (a1, a2) (b1, b2) = (a1 + b1, a2 + b2)


-- ok, here's where you come in

-- we want to create a function play, that takes the two lists of hands
-- the players have played, computes the score at each round, then
-- combines all the scores to yield the final count

-- this functions is pre-defined, using the ($) operator, to showcase
-- how easily you can combine existing functions into new ones; your job
-- is to figure out which function goes where

-- here is the list of functions you will need:
--     combine      :: Score -> Score -> Score
--     computeScore :: Hand  -> Hand  -> Score
--     uncurry      :: (a -> b -> c) -> ((a, b) -> c)
--     foldl1       :: (a -> a -> a) -> [a] -> a
--     map          :: (a -> b) -> [a] -> [b]
--     zip          :: [a] -> [b] -> [(a, b)]

pairScore :: (Hand, Hand) -> Score
pairScore = uncurry computeScore

score :: [Hand] -> [Hand] -> Score
score h1 h2 = foldl1 combine $ map pairScore $ zip h1 h2

-- hint: it creates a list of plays by merging the two lists,
--       then it scores each play,
--       then it sums the scores.
--       merge -> map -> reduce


-- we play up to 3

gameOver :: Score -> Bool
gameOver (s1, s2) = s1 >= 3 || s2 >= 3


-- below is the impure IO code that lets us read hands from the
-- standard input and play the game!
-- beware: Haskell 102 spoilers!

readHand :: String -> IO Hand
readHand prompt = do
  putStr prompt                  -- prints the prompt
  handText <- getLine            -- reads one line of input
  case readMaybe handText of     -- tries to convert it to Hand
     Just h  -> return h         -- success: our result is h
     Nothing -> readHand prompt  -- failure: we try again

playTurn :: Score -> IO Score
playTurn oldScore = do
  h1 <- readHand "p1: "
  h2 <- readHand "p2: "
  let turnScore = computeScore h1 h2
      newScore  = combine oldScore turnScore
  print newScore
  if gameOver newScore
    then return   newScore
    else playTurn newScore

play :: IO ()
play = void $ playTurn (0,0)





{- #####################################################################
   BONUS BONUS SECTION: wait, you actually read all of that?

   Just for fun, here are a few common one-liners; can you guess what
   they do, what they are, without testing them in GHCI?
-}


-- all fibonacci numbers (infinite list)
mystic :: [Integer]
mystic = 0 : 1 : zipWith (+) mystic (tail mystic)

fibonacci :: [Integer]
fibonacci = fib 0 1
  where fib a b = a : fib b (a+b)


-- all prime numbers (infinite list)
valor :: [Integer]
valor = let s l = head l : s [n | n <- tail l, n `mod` head l /= 0] in s [2..]


allPrimes :: [Integer]
allPrimes = sieve [2..]
  where sieve []     = error "this cannot happen"
        sieve (x:xs) = x : sieve (filter (not . isDividableBy x) xs)
        isDividableBy x n = n `mod` x == 0


-- quicksort (sort of)
-- although this is close to quicksort in spirit, it does a lot of copying and
-- is not as efficient as a typical quicksort implementation.

instinct :: [Int] -> [Int]
instinct []     = []
instinct (x:xs) = instinct [a | a <- xs, a < x] ++ [x] ++ instinct (filter (>= x) xs)

qsort :: Ord a => [a] -> [a] -- for all types a that provide (>) and (<=)
qsort [] = []
qsort (pivot:list) = qsort smaller ++ [pivot] ++ qsort bigger
  where smaller = filter (<= pivot) list
        bigger  = filter (>  pivot) list
