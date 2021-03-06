-- OuterInner.hs
module OuterInner where

import Control.Monad.Trans.Except
import Control.Monad.Trans.Maybe
import Control.Monad.Trans.Reader


embedded :: MaybeT (ExceptT String (ReaderT () IO)) Int
embedded = return 1

maybeUnwrap :: ExceptT String (ReaderT () IO) (Maybe Int)
maybeUnwrap = runMaybeT embedded

eitherUnwrap :: ReaderT () IO (Either String (Maybe Int))
eitherUnwrap = runExceptT maybeUnwrap

readerUnwrap :: () -> IO (Either String (Maybe Int))
readerUnwrap = runReaderT eitherUnwrap

-- Wrap It Up
embedded' :: MaybeT (ExceptT String (ReaderT () IO)) Int
--
-- embedded' = runReaderT (const (Right (Just 1)))
-- embedded' = runMaybeT (const (Right (Just 1)))
--
-- (FROM ANSWER KEY: https://github.com/johnchandlerburnham/hpfp)
embedded' = MaybeT $ ExceptT $ ReaderT $ pure <$> (const (Right (Just 1)))
