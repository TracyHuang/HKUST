package hk.ust.cse.TwitterClient.Controls;

import hk.ust.cse.TwitterClient.Views.TweetView;

import org.eclipse.swt.widgets.Display;

import twitter4j.RelatedResults;
import twitter4j.ResponseList;
import twitter4j.Status;

public class TweetViewControl {

  public TweetViewControl(TweetView view) {
    m_view = view;
  }
  
  public void getRepliesCallback(final Object retValue) {
    Runnable runnable = new Runnable() {
      public void run() {
        RelatedResults relatedResults = (RelatedResults) retValue;
        ResponseList<Status> replies = relatedResults.getTweetsWithConversation();
        m_view.showReplies(replies);
      }
    };
    Display.getDefault().asyncExec(runnable);
  }
  
  private final TweetView m_view;
}
