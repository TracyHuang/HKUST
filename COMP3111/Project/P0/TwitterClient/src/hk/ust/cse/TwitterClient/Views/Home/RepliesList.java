package hk.ust.cse.TwitterClient.Views.Home;

import hk.ust.cse.TwitterClient.Resources.Resources;
import hk.ust.cse.TwitterClient.Views.ListView;
import hk.ust.cse.TwitterClient.Views.TweetView;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.swt.SWT;
import org.eclipse.swt.events.DisposeEvent;
import org.eclipse.swt.events.DisposeListener;
import org.eclipse.swt.layout.RowData;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;

import twitter4j.Status;

public class RepliesList extends ListView {
  
  public RepliesList(Composite parentView, List<Status> tweets, 
      int width, String nameClkHandler, Object handlerCallee) {
    super(parentView, null, width, null, null, null, null);
    
    m_tweets = tweets;

    m_nameClkHandler = nameClkHandler;
    m_handlerCallee  = handlerCallee;
    
    initialze(width);
    
    // a dispose listener is necessary
    addDisposeListener(new DisposeListener() {
      public void widgetDisposed(DisposeEvent e) {
        RepliesList.this.widgetDisposed(e);
      }
    });
  }
  
  private void initialze(int width) {
    List<Composite> tweetViews = new ArrayList<Composite>();
    if (m_tweets != null) {
      for (Status tweet : m_tweets) {
        tweet = tweet.getRetweetedStatus() != null ? tweet.getRetweetedStatus() : tweet;
        final TweetView tweetView = new TweetView(this, tweet, width, false, 
            Resources.HOVER_COLOR, Resources.HOVER_COLOR, Resources.HOVER_COLOR, m_nameClkHandler, m_handlerCallee);
        tweetView.addListener(SWT.Resize, new Listener() {
          @Override
          public void handleEvent(Event arg0) {
            tweetView.setLayoutData(new RowData(tweetView.getBounds().width, 
                                                tweetView.getBounds().height));
            layout();
            pack();
          }
        });
        tweetView.setBackground(Resources.HOVER_COLOR);
        tweetViews.add(tweetView);
      }
    }
    addItems(tweetViews);
  }
  
  private void widgetDisposed(DisposeEvent e) {
  }
  
  private String m_nameClkHandler;
  private Object m_handlerCallee;
  
  private final List<Status> m_tweets;
}
