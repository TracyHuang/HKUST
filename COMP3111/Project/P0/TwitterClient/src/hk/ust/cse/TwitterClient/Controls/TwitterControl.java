package hk.ust.cse.TwitterClient.Controls;

import java.lang.reflect.Method;
import java.util.HashMap;

import twitter4j.AsyncTwitter;
import twitter4j.PagableResponseList;
import twitter4j.Paging;
import twitter4j.RelatedResults;
import twitter4j.ResponseList;
import twitter4j.Status;
import twitter4j.Twitter;
import twitter4j.TwitterAdapter;
import twitter4j.TwitterException;
import twitter4j.User;

public class TwitterControl {
  
  public static void setupTwitter(Twitter twitter, AsyncTwitter asyncTwitter) {
    s_twitter      = twitter;
    s_asyncTwitter = asyncTwitter;
    s_callbacks    = new HashMap<String, Object[]>();
    
    try {
      s_accountUser = getUser(s_twitter.getScreenName());
    } catch (TwitterException e) {e.printStackTrace();}
    
    s_asyncTwitter.addListener(new TwitterAdapter() {
      @Override
      public void gotHomeTimeline(ResponseList<Status> statuses) {
        invokeCallback("getHomeTimeline", statuses);
      }
      
      @Override
      public void gotUserTimeline(ResponseList<Status> statuses) {
        invokeCallback("getUserTimeline", statuses);
      }

      @Override
      public void gotFollowersList(PagableResponseList<User> followersList) {
        invokeCallback("getFollowersList", followersList);
      }
      
      @Override
      public void gotFriendsList(PagableResponseList<User> friendsList) {
        invokeCallback("getFriendsList", friendsList);
      }
      
      @Override
      public void gotRelatedResults(RelatedResults relatedResults) {
        invokeCallback("getRelatedResults", relatedResults);
      }

      @Override
      public void onException(TwitterException te, twitter4j.TwitterMethod method)  {
        te.printStackTrace();
      }
      
      private void invokeCallback(String methodName, Object returnVal) {
        Object[] callback = s_callbacks.get(methodName);
        if (callback != null) {
          try {
            Method method = callback[0].getClass().getMethod(
                (String) callback[1], new Class<?>[] {(Class<?>) Object.class});
            method.invoke(callback[0], returnVal);
          } catch (Exception e) {e.printStackTrace();}
        }
      }
    });
  }
  
  public static void getHomeTimeline(int page, String callback, Object callee) {
    s_callbacks.put("getHomeTimeline", new Object[] {callee, callback});
    s_asyncTwitter.getHomeTimeline(new Paging(page));
  }
  
  public static void getUserTimeline(String screenName, int page, String callback, Object callee) {
    s_callbacks.put("getUserTimeline", new Object[] {callee, callback});
    s_asyncTwitter.getUserTimeline(screenName, new Paging(page));
  }

  public static void getFollowers(String screenName, long cursor, String callback, Object callee) {
    s_callbacks.put("getFollowersList", new Object[] {callee, callback});
    s_asyncTwitter.getFollowersList(screenName, cursor);
  }

  public static void getFollowing(String screenName, long cursor, String callback, Object callee) {
    s_callbacks.put("getFriendsList", new Object[] {callee, callback});
    s_asyncTwitter.getFriendsList(screenName, cursor);
  }
  
  public static void getReplies(Status tweet, String callback, Object callee) {
    s_callbacks.put("getRelatedResults", new Object[] {callee, callback});
    s_asyncTwitter.getRelatedResults(tweet.getId());
  }

  // return null if user not found
  public static User getAccountUser() {
    return s_accountUser;
  }
  
  // return null if user not found
  public static User getUser(String screenName) {
    User user = null;
    try {
      user = s_twitter.showUser(screenName);
    } catch (TwitterException e) {e.printStackTrace();}
    return user;
  }
  
  public static Twitter getTwitter() {
    return s_twitter;
  }
  
  private static Twitter      s_twitter;
  private static AsyncTwitter s_asyncTwitter;
  private static User         s_accountUser;
  
  private static HashMap<String, Object[]> s_callbacks;
}
