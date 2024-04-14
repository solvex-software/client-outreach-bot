

module Main where


import Scrappy.Requests
import Scrappy.Scrape
import Scrappy.Links
import Scrappy.Elem

import Control.Monad (mapM_)

import Text.Parsec

--import Text.URI
import Network.URI (uri)
import Data.List
-- implement SiteT at some point

type PostalCodeArea = String
type IndustryPair = (Industry, PostalCodeArea) 

link = Link "https://www.google.com/maps/search/M6H+realtors/"


andAll :: a -> [(a -> Bool)] -> Bool
andAll s checks = all ($ s) checks

uri' = do
  u <- uri
  let
    checks = [ isPrefixOf "http"
             , not . isInfixOf "google"
             , not . isSuffixOf ".png"
             , not . elem '?'
             , not . isSuffixOf ".jpg"
             , not . isInfixOf "gstatic"
             , not . isInfixOf ".ggpht"
             , (9 <) . length
             ]
  case andAll (show u) checks of 
    True -> pure u
    False -> parserZero

main :: IO ()
main = do
  -- mgr <- newCookiedManager 
  -- getHtmlST mgr link >>= pure . scrape uri' . fst >>= \case
  --   Nothing -> print "nothing"
  --   Just x -> do
  --     --mapM_ print x
  --     pure ()

  flip runStateT ([], industryPairs) $ do
    loopState 
    
  pure () 


newtype SpamBotState = SpamBotState
  { sites :: [Url]
  , industryPairs :: [IndustryPair]
  , manager :: CookieManager
  , wdSession :: WDSession 
  } 

loopState :: StateT SpamBotState m -> m ()
loopState = do
  fst <$> get >>= \case
    [] -> getLinksFromGoogle
    (site:moreSites) -> do
      runSite site
      modify $ \s -> s { sites = moreSites }

getLinksFromGoogle :: MonadIO m => StateT SpamBotState m [Url]
getLinksFromGoogle = do
  sesh <- gets wdSession
  (industry, area) <- consumeUnsafe industryPairs
  let link = Link "https://www.google.com/maps/search/" <> area <> "+" <> (show industry)
  getHtmlST sesh link >>= pure . scrape uri' . fst >>= \case
    Nothing -> do
      print "Warning: no links found on " <> (show link)
      pure ()
    Just newSites -> modify $ \s -> s { sites = newSites } 


