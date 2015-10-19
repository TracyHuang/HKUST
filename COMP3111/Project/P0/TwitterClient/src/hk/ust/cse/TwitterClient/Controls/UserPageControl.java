package hk.ust.cse.TwitterClient.Controls;

import hk.ust.cse.TwitterClient.Views.User.UserPage;

import org.eclipse.swt.widgets.Display;

import twitter4j.PagableResponseList;
import twitter4j.ResponseList;
import twitter4j.Status;
import twitter4j.User;

public class UserPageControl {

  public UserPageControl(UserPage view) {
    m_view = view;
  }

  @SuppressWarnings("unchecked")
  public void showTweetsListCallback(final Object retValue) {
    Runnable runnable = new Runnable() {
      public void run() {
        ResponseList<Status> tweets = (ResponseList<Status>) retValue;
        m_view.showTweetsList(tweets);
      }
    };
    Display.getDefault().asyncExec(runnable);
  }
  
  @SuppressWarnings("unchecked")
  public void showFollowingListCallback(final Object retValue) {
    Runnable runnable = new Runnable() {
      public void run() {
        PagableResponseList<User> following = (PagableResponseList<User>) retValue;
        m_view.showFollowingList(following);
      }
    };
    Display.getDefault().asyncExec(runnable);
  }
  
  @SuppressWarnings("unchecked")
  public void showFollowersListCallback(final Object retValue) {
    Runnable runnable = new Runnable() {
      public void run() {
        PagableResponseList<User> followers = (PagableResponseList<User>) retValue;
        m_view.showFollowersList(followers);
      }
    };
    Display.getDefault().asyncExec(runnable);
  }
  
  private final UserPage m_view;
}
