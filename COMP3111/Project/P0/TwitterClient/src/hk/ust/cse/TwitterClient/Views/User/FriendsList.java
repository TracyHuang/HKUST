package hk.ust.cse.TwitterClient.Views.User;

import hk.ust.cse.TwitterClient.Utils;
import hk.ust.cse.TwitterClient.Views.ListView;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.swt.events.DisposeEvent;
import org.eclipse.swt.events.DisposeListener;
import org.eclipse.swt.widgets.Composite;

import twitter4j.PagableResponseList;
import twitter4j.User;

public class FriendsList extends ListView {
  
  public FriendsList(Composite parentView, PagableResponseList<User> friends, 
      String title, int width, String nameClkHandler, Object handlerCallee, 
      String backHandler, Object backHandlerCallee, String nextHandler, Object nextHandlerCallee) {
    super(parentView, title, width, backHandler, backHandlerCallee, nextHandler, nextHandlerCallee);
    
    m_friends = friends;

    m_nameClkHandler = nameClkHandler;
    m_handlerCallee  = handlerCallee;
    
    initialze();
    
    // a dispose listener is necessary
    addDisposeListener(new DisposeListener() {
      public void widgetDisposed(DisposeEvent e) {
        FriendsList.this.widgetDisposed(e);
      }
    });
  }
  
  private void initialze() {
    List<Composite> friendViews = new ArrayList<Composite>();
    if (m_friends != null) {
      for (User friend : m_friends) {
        friendViews.add(new FriendView(this, friend, getBounds().width, m_nameClkHandler, m_handlerCallee));
      }
    }
    addItems(friendViews);
    
    // cut corner only after layout()
    Utils.cutRoundCorner(this, true, true, true, true);
  }
  
  private void widgetDisposed(DisposeEvent e) {
  }
  
  private String m_nameClkHandler;
  private Object m_handlerCallee;
  
  private final PagableResponseList<User> m_friends;
}
