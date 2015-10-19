package hk.ust.cse.TwitterClient.Views.User;

import hk.ust.cse.TwitterClient.Utils;
import hk.ust.cse.TwitterClient.Resources.Resources;
import hk.ust.cse.TwitterClient.Views.ListView;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;

import org.eclipse.swt.events.DisposeEvent;
import org.eclipse.swt.events.DisposeListener;
import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;

public class UserMenu extends ListView {
  
  public UserMenu(Composite parentView, int width, int height, String itmClkHandler, Object handlerCallee) {
    super(parentView, width);
    
    m_itmClkHandler = itmClkHandler;
    m_handlerCallee = handlerCallee;
    
    initialize(width, height);
    
    // a dispose listener is necessary
    addDisposeListener(new DisposeListener() {
      public void widgetDisposed(DisposeEvent e) {
        UserMenu.this.widgetDisposed(e);
      }
    });
  }
  
  private void initialize(int width, int height) {
    // menu items
    String[] titles = new String[] {"Tweets", "Following", "Followers", /*"Favorites", "Lists"*/};
    
    // set the number views
    m_items = new ArrayList<UserMenuItem>();;
    int singleHeight = height / titles.length;
    for (int i = 0; i < titles.length; i++) {
      UserMenuItem item = new UserMenuItem(this, 
          titles[i], width, singleHeight, Resources.FONT11, Resources.FONT11B);
      Utils.addClickListener(item, "onMenuItemClicked", this);
      m_items.add(item);
    }
    addItems(m_items);
    m_currSelected = 0;
    
    // cut corner only after layout()
    Utils.cutRoundCorner(this, true, true, true, true);
  }
  
  private void widgetDisposed(DisposeEvent e) {
  }
  
  public void onMenuItemClicked(MouseEvent arg) {
    Control clicked = (Control) arg.getSource();
    while (!(clicked instanceof UserMenuItem)) {
      clicked = clicked.getParent();
    }
    if (clicked != null) {
      setCurrentSelected(m_items.indexOf(clicked));
    }
    
    if (m_itmClkHandler != null) {
      try {
        Method method = m_handlerCallee.getClass().getMethod(m_itmClkHandler, MouseEvent.class);
        method.invoke(m_handlerCallee, arg);
      } catch (Exception e) {}
    }
  }
  
  public void setCurrentSelected(int currSelected) {
    m_items.get(m_currSelected).setNotClicked();
    m_currSelected = currSelected;
    m_items.get(m_currSelected).setClicked();
  }
  
  public int getCurrentSelected() {
    return m_currSelected;
  }
  
  public List<UserMenuItem> getMenuItems() {
    return m_items;
  }
  
  private final String m_itmClkHandler;
  private final Object m_handlerCallee;

  private int                m_currSelected;
  private List<UserMenuItem> m_items;
}
