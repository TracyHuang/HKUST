package hk.ust.cse.TwitterClient.Views.User;

import hk.ust.cse.TwitterClient.Utils;
import hk.ust.cse.TwitterClient.Resources.Resources;
import hk.ust.cse.TwitterClient.Views.Basic.ClickableImageLabel;
import hk.ust.cse.TwitterClient.Views.Basic.LinkLabel;
import hk.ust.cse.TwitterClient.Views.Basic.RowComposite;

import org.eclipse.swt.SWT;
import org.eclipse.swt.events.DisposeEvent;
import org.eclipse.swt.events.DisposeListener;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.layout.RowData;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;

import twitter4j.User;

public class FriendView extends RowComposite {
  
  public FriendView(Composite parentView, User friend, int width, String nameClkHandler, Object handlerCallee) {
    super(parentView, SWT.CENTER, SWT.HORIZONTAL, false, 12, 12, 12, 12, 5);
    
    m_friend = friend;

    m_nameClkHandler = nameClkHandler;
    m_handlerCallee  = handlerCallee;
    
    initialize(width);
    
    // a dispose listener is necessary
    addDisposeListener(new DisposeListener() {
      public void widgetDisposed(DisposeEvent e) {
        FriendView.this.widgetDisposed(e);
      }
    });
  }
  
  private void initialize(int width) {
    // set size
    setSize(width, -1);
    
    // set background color
    setBackground(Resources.WHITE_COLOR);
    setBackgroundMode(SWT.INHERIT_DEFAULT); // make all labels have transparent backgrounds
    
    // set profile icon
    if (m_friend.getProfileImageURL() != null) {
      m_iconImage = Utils.loadImageFromUrlAndScale(m_friend.getProfileImageURL(), 48, 48);
    }
    m_icon = new ClickableImageLabel(this, 0, m_iconImage, m_iconImage, m_nameClkHandler, m_handlerCallee);
    m_icon.setLayoutData(new RowData(48, 48));
    
    // set the right frame
    RowComposite rightFrame = new RowComposite(this, 0, SWT.VERTICAL, false, 0, 0, 5, 5, 3);
    rightFrame.setLayoutData(new RowData(getBounds().width - 77, -1));

    // set the right upper frame
    RowComposite rightUpFrame = new RowComposite(rightFrame, 0, SWT.HORIZONTAL, false, 0, 0, 0, 0, 5);
    
    // set name, verified icon and screen name
    m_name = new LinkLabel(rightUpFrame, 0, 
        Resources.TEXT_COLOR, Resources.LINK_COLOR, Resources.FONT11B, Resources.FONT11B);
    m_name.setText(m_friend.getName());
    Utils.addClickListener(m_name, m_nameClkHandler, m_handlerCallee);
    
    if (m_friend.isVerified()) {
      m_verified = new Label(rightUpFrame, SWT.CENTER);
      m_verified.setImage(Resources.VERIFIED_IMG);
    }
    
    m_screenName = new Label(rightUpFrame, 0);
    m_screenName.setFont(Resources.FONT10);
    m_screenName.setForeground(Resources.GRAY_COLOR);
    m_screenName.setText("@" + m_friend.getScreenName());
    
    // set text
    m_textColor = new Color(null, 119, 119, 119);
    m_text = new Label(rightFrame, SWT.WRAP | SWT.LEFT);
    m_text.setFont(Resources.FONT11I);
    m_text.setForeground(m_textColor);
    m_text.setText(m_friend.getDescription().replace('\n', ' '));
    m_text.setLayoutData(new RowData(getBounds().width - 105, -1));

    layout(); // trigger re-layout
    pack(); // force re-size of height, the width should not be changed
    
//    // cut corner only after layout()
//    Utils.cutRoundCorner(m_iconImage, true, true, true, true);
  }
  
  private void widgetDisposed(DisposeEvent e) {
    // dispose loaded images
    Utils.dispose(m_iconImage);
    
    // dispose loaded colors
    Utils.dispose(m_textColor);
  }
  
  public User getFriend() {
    return m_friend;
  }

  private ClickableImageLabel m_icon;
  private Label m_name;
  private Label m_verified;
  private Label m_screenName;
  private Label m_text;

  private String m_nameClkHandler;
  private Object m_handlerCallee;
  
  // resources that need to be disposed
  private Image m_iconImage;
  private Color m_textColor;
  
  private final User m_friend;
}

