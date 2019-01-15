{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import           Control.Concurrent (threadDelay)
import           Data.Foldable      (forM_)
import           Data.Text          (Text)
import           Data.Text          (pack)
import           Network.WebSockets (ServerApp)

import qualified Control.Concurrent as Concurrent
import qualified Data.Text          as Text
import qualified Network.WebSockets as WS


main :: IO ()
main = WS.runServer "127.0.0.1" 9160 application


application :: ServerApp
application pending = do
  c <- WS.acceptRequest pending

  forM_ [1..] $ \i -> do
    WS.forkPingThread c 10
    WS.sendTextData c (pack $ show (i :: Int)) >> threadDelay 100000
