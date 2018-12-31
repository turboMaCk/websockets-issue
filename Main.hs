{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import           Control.Concurrent (MVar)
import           Control.Exception  (finally)
import           Control.Monad      (forM_, forever)
import           Data.Text          (Text)
import           Network.WebSockets (Connection, ServerApp)

import qualified Control.Concurrent as Concurrent
import qualified Data.Text          as Text
import qualified Network.WebSockets as WS


type Client =
  (Int, Connection)

type ServerState =
  [Client]

addClient :: Client -> ServerState -> ServerState
addClient client clients =
  client : clients

removeClient :: Client -> ServerState -> ServerState
removeClient client =
  filter ((/= (fst client)) . fst)

broadcast :: Text -> ServerState -> IO ()
broadcast message clients =
    forM_ clients $ \(_, conn) -> WS.sendTextData conn message

main :: IO ()
main = do
  state <- Concurrent.newMVar []
  WS.runServer "127.0.0.1" 9160 $ application state

application :: MVar ServerState -> ServerApp
application state pending = do
  conn <- WS.acceptRequest pending
  WS.forkPingThread conn 30
  msg :: Text <- WS.receiveData conn
  clients <- Concurrent.readMVar state
  let client = (length clients, conn)

  flip finally (disconnect client) $ do
    Concurrent.modifyMVar_ state $ \s -> do
      let s' = addClient client s
      return s'

    forever $ do
      msg :: Text <- WS.receiveData conn
      pure ()
  where
    disconnect client = do
      Concurrent.modifyMVar state $ \s ->
        let s' = removeClient client s
        in pure (s', s')
