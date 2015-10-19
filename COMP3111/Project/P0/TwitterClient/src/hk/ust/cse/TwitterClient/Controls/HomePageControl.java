package hk.ust.cse.TwitterClient.Controls;

import hk.ust.cse.TwitterClient.Views.Home.HomePage;

import org.eclipse.swt.widgets.Display;

import twitter4j.ResponseList;
import twitter4j.Status;

public class HomePageControl {

  public HomePageControl(HomePage view) {
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
  
  private final HomePage m_view;
}
