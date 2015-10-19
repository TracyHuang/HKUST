package hk.ust.cse.TwitterClient.Views.Home;

import hk.ust.cse.TwitterClient.Utils;
import hk.ust.cse.TwitterClient.Controls.HomePageControl;
import hk.ust.cse.TwitterClient.Controls.TwitterControl;
import hk.ust.cse.TwitterClient.Resources.Resources;
import hk.ust.cse.TwitterClient.Views.NumberBar;
import hk.ust.cse.TwitterClient.Views.TweetsList;
import hk.ust.cse.TwitterClient.Views.Basic.RowComposite;

import java.util.List;

import org.eclipse.swt.SWT;
import org.eclipse.swt.events.DisposeEvent;
import org.eclipse.swt.events.DisposeListener;
import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.layout.RowData;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;

import twitter4j.Status;
import twitter4j.User;

public class HomePage extends RowComposite {
  
  public HomePage(Composite parentView, int width, int minPageHeight, final int miniProfileWidth, 
      int miniProfileHeight, int itemListWidth, String nameClkHandler, String numItemClkHandler, Object handlerCallee) {
    super(parentView, SWT.CENTER, SWT.HORIZONTAL, false, 25, 50, 
        (width - miniProfileWidth - itemListWidth - 20) / 2, 
        (width - miniProfileWidth - itemListWidth - 20) / 2, 20);

    m_user              = TwitterControl.getAccountUser();
    m_width             = width;
    m_minPageHeight     = minPageHeight;
    m_nameClkHandler    = nameClkHandler;
    m_numItemClkHandler = numItemClkHandler;
    m_handlerCallee     = handlerCallee;
    m_control           = new HomePageControl(this);
    
    initialize(width, miniProfileWidth, miniProfileHeight, 
        itemListWidth, minPageHeight, nameClkHandler, handlerCallee);
    
    showHomeTimeline();
    
    // a dispose listener is necessary
    addDisposeListener(new DisposeListener() {
      public void widgetDisposed(DisposeEvent e) {
        HomePage.this.widgetDisposed(e);
      }
    });
  }
  
  private void initialize(int width, int miniProfileWidth, int miniProfileHeight, 
      int itemListWidth, int minPageHeight, String nameClkHandler, Object handlerCallee) {
    // set size
    setSize(width, -1);
    
    // set background color
    m_bgColor = Utils.getColorFromString(m_user.getProfileBackgroundColor());
    setBackground(m_bgColor);
    setBackgroundMode(SWT.INHERIT_DEFAULT); // make all labels have transparent backgrounds
    
    // set background image
    m_bgImage = Utils.loadImageFromUrl(m_user.getProfileBackgroundImageURL().toString());
    if (m_bgImage != null) {
      setBackgroundImage(m_bgImage);
    }

    // set the left frame for mini-profile
    RowComposite leftFrame = new RowComposite(this, 0, SWT.VERTICAL, false, 0, 0, 0, 0, 0);
    leftFrame.setBackground(Resources.WHITE_COLOR);
    leftFrame.setLayoutData(new RowData(miniProfileWidth, -1));
    
    // set the left mini-profile
    m_miniProfile = new MiniProfile(leftFrame, m_user, miniProfileWidth, miniProfileHeight);
    m_miniProfile.setLayoutData(new RowData(miniProfileWidth, miniProfileHeight));
    Utils.addClickListener(m_miniProfile, m_nameClkHandler, m_handlerCallee);
    
    // set the left number bar
    long[] numbers = new long[] {m_user.getStatusesCount(), 
                                 m_user.getFriendsCount(), 
                                 m_user.getFollowersCount()};
    String[] titles = new String[] {"TWEETS", "FOLLOWING", "FOLLOWERS"};
    m_numberBar = new NumberBar(leftFrame, numbers, titles, miniProfileWidth, 90, 50, 
        Resources.MINI_PROFILE_COLOR, Resources.MINI_PROFILE_COLOR, Resources.MINI_PROFILE_COLOR, 
        Resources.FONT11B, Resources.FONT7, true, m_numItemClkHandler, m_handlerCallee);
    m_numberBar.setLayoutData(new RowData(miniProfileWidth, 50));

    // set the right frame
    m_rightFrame = new RowComposite(this, 0, SWT.VERTICAL, false, 0, 0, 0, 0, -1);
    m_rightFrame.setLayoutData(new RowData(itemListWidth, -1));
    m_rightFrame.addListener(SWT.Resize, new Listener() {
      @Override
      public void handleEvent(Event arg0) {
        m_rightFrame.setLayoutData(new RowData(m_rightFrame.getBounds().width, 
                                               m_rightFrame.getBounds().height));
        layout();
        pack();
      }
    });
    
    layout(); // trigger re-layout
    pack();
    
    Utils.cutRoundCorner(leftFrame, true, true, true, true);
    Utils.cutRoundCorner(m_miniProfile, true, true, false, false);
    Utils.cutRoundCorner(m_numberBar, false, false, true, true);
  }
  
  private void showHomeTimeline() {
    // remove the old list view
    Utils.dispose(m_itemList);
    
    layout();
    pack();

    // we need to guarantee a minimal page height
    if (getBounds().height < m_minPageHeight) {
      setSize(m_width, m_minPageHeight);
    }
    
    // retrieve the list asynchronously
    m_tweetPage = 1;
    TwitterControl.getHomeTimeline(m_tweetPage, "showTweetsListCallback", m_control);
  }
  
  public void tweetsListBackClicked(MouseEvent arg) {
    if (m_tweetPage > 1) {
      m_tweetPage -= 1;
      TwitterControl.getHomeTimeline(m_tweetPage, "showTweetsListCallback", m_control);
    }
  }
  
  public void tweetsListNextClicked(MouseEvent arg) {
    m_tweetPage += 1;
    TwitterControl.getHomeTimeline(m_tweetPage, "showTweetsListCallback", m_control);
  }
  
  public void showTweetsList(List<Status> tweets) {
    // remove the old list view
    Utils.dispose(m_itemList);
    layout();

    m_itemList = new TweetsList(m_rightFrame, tweets, 
        m_rightFrame.getBounds().width, m_nameClkHandler, m_handlerCallee, 
        "tweetsListBackClicked", this, "tweetsListNextClicked", this);
    m_itemList.addListener(SWT.Resize, new Listener() {
      @Override
      public void handleEvent(Event arg0) {
        m_itemList.setLayoutData(new RowData(m_itemList.getBounds().width, 
                                             m_itemList.getBounds().height));
        m_rightFrame.layout();
        m_rightFrame.pack();
      }
    });
    m_rightFrame.layout();
    m_rightFrame.pack();
    
    // we need to guarantee a minimal page height
    if (getBounds().height < m_minPageHeight) {
      setSize(m_width, m_minPageHeight);
    }
  }
  
  private void widgetDisposed(DisposeEvent e) {
    // dispose created colors
    Utils.dispose(m_bgColor);
    
    // dispose loaded images
    Utils.dispose(m_bgImage);
  }

  private MiniProfile  m_miniProfile;
  private NumberBar    m_numberBar;
  private TweetsList   m_itemList;
  private RowComposite m_rightFrame;

  // the currently showing list
  private int m_tweetPage;
  
  // resources that need to be disposed
  private Color m_bgColor;
  private Image m_bgImage;
  
  private final User            m_user;
  private final int             m_width;
  private final int             m_minPageHeight;
  private final String          m_nameClkHandler;
  private final String          m_numItemClkHandler;
  private final Object          m_handlerCallee;
  private final HomePageControl m_control;
}
