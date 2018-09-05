{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell     #-}
{-# LANGUAGE TypeApplications    #-}
{-# OPTIONS_GHC -fno-warn-missing-signatures #-}
{-# OPTIONS_GHC -fno-warn-deprecations #-}

module Test.Data.Registry.Internal.ReflectionSpec where

import           Data.Registry.Internal.Reflection
import           Prelude                           (String)
import           Protolude                         as P
import           Test.Tasty.Extensions

test_show_value = test "show value for a simple type" $ do
  showValue (1 :: Int)      === "Int: 1"
  showValue (1 :: Double)   === "Double: 1.0"
  showValue (True :: Bool)  === "Bool: True"
  showValue ("1" :: Text)   === "Text: \"1\""
  showValue ("1" :: String) === "String: \"1\""

test_show_value_nested_type = test "show value for a nested types" $ do
  showValue (Just 1 :: Maybe Int)        === "Maybe Int: Just 1"


  -- putting parentheses around types doesn't really work when type constructors
  -- have more than one argument :-(
  showValue (Right 1 :: Either Text Int) === "Either (Text Int): Right 1"
  showValue ([1] :: [Int])               === "[Int]: [1]"

  -- user types must be shown with their full module names
  showValue mod1                         === "Test.Data.Registry.Internal.ReflectionSpec.Mod Int: Mod 1 \"hey\""

test_show_function = test "show simple functions" $ do
  showFunction add1  === "Int -> Int"
  showFunction add2  === "Int -> Int -> Text"
  showFunction iomod === "IO (Test.Data.Registry.Internal.ReflectionSpec.Mod Int)"

  showFunction fun0  === "IO Int"
  showFunction fun1  === "IO Int -> IO Int"
  showFunction fun2  === "IO Int -> IO Int -> IO Int"
  showFunction fun3  === "IO (Test.Data.Registry.Internal.ReflectionSpec.Mod Int) -> IO Int"

data Mod a = Mod a Text deriving (Eq, Show)

mod1 :: Mod Int
mod1 = Mod 1 "hey"

iomod :: IO (Mod Int)
iomod = pure (Mod 1 "hey")

add1 :: Int -> Int
add1 i = i + 1

add2 :: Int -> Int -> Text
add2 _ = undefined

fun0 :: IO Int
fun0 = undefined

fun1 :: IO Int -> IO Int
fun1 = undefined

fun2 :: IO Int -> IO Int -> IO Int
fun2 = undefined

fun3 :: IO (Mod Int) -> IO Int
fun3 = undefined

----
tests = $(testGroupGenerator)