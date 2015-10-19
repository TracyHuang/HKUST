package hk.ust.cse.TwitterClient.Views.Home;

import hk.ust.cse.TwitterClient.Utils;
import hk.ust.cse.TwitterClient.Resources.Resources;
import hk.ust.cse.TwitterClient.Views.Basic.ClickableComposite;
import hk.ust.cse.TwitterClient.Views.Basic.RowComposite;

import org.eclipse.swt.SWT;
import org.eclipse.swt.events.DisposeEvent;
import org.eclipse.swt.events.DisposeListener;
import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.events.MouseTrackListener;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.layout.RowData;
import org.eclipse.swt.layout.RowLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;

import twitter4j.User;

public class MiniProfile extends ClickableComposite {
  
  public MiniProfile(Composite parentView, User user, int width, int height) {
    super(parentView);
    
    m_user = user;
    
    initialize(width, height);
    
    addMouseTrackListener(new MouseTrackListener() {
      @Override
      public void mouseHover(MouseEvent arg0) {
      }
      
      @Override
      public void mouseExit(MouseEvent arg0) {
        Rectangle rect = MiniProfile.this.getClientArea();
        if (!rect.contains(arg0.x, arg0.y)) {
          m_name.setForeground(Resources.TEXT_COLOR);
          m_name.setFont(Resources.FONT11B);
        }
      }
      
      @Override
      public void mouseEnter(MouseEvent arg0) { 
        m_name.setForeground(Resources.LINK_COLOR);
        m_name.setFont(Resources.FONT11B);
      }
    });
    
    // a dispose listener is necessary
    addDisposeListener(new DisposeListener() {
      public void widgetDisposed(DisposeEvent e) {
        MiniProfile.this.widgetDisposed(e);
      }
    });
  }
  
  // initialize widgets within the mini profile composite
  private void initialize(int width, int height) {
    // set size
    setSize(width, height);
    
    // set layout of the view
    RowLayout layout = new RowLayout(SWT.HORIZONTAL);
    layout.center       = true;
    layout.marginTop    = 0;
    layout.marginBottom = 0;
    layout.marginLeft   = 12;
    layout.marginRight  = 12;
    layout.spacing      = 12;
    setLayout(layout);
    
    // set background color
    setBackground(Resources.MINI_PROFILE_COLOR);
    setBackgroundMode(SWT.INHERIT_DEFAULT); // make all labels have transparent backgrounds
    
    // set profile icon
    m_icon = new Label(this, 0);
    if (m_user.getOriginalProfileImageURL() != null) {
      m_iconImage = Utils.loadImageFromUrlAndScale(m_user.getOriginalProfileImageURL(), 32, 32);
      if (m_iconImage != null) {
        m_icon.setImage(m_iconImage);
      }
    }
    m_icon.setLayoutData(new RowData(32, 32));

    // set name's outer frame
    RowComposite nameFrame = new RowComposite(this, 0, SWT.VERTICAL, false, 10, 10, 0, 0, 1);
    nameFrame.setLayoutData(new RowData(width - 68, height));
    
    // set name
    m_name = new Label(nameFrame, 0);
    m_name.setFont(Resources.FONT11B);
    m_name.setForeground(Resources.TEXT_COLOR);
    m_name.setText(m_user.getName());
    
    // set "view my profile" string
    m_view = new Label(nameFrame, SWT.CENTER);
    m_view.setFont(Resources.FONT8);
    m_view.setForeground(Resources.GRAY_COLOR);
    m_view.setText("View my profile page");
    
    layout(); // trigger re-layout
    
//    // cut corner only after layout()
//    Utils.cutRoundCorner(m_icon, true, true, true, true);
  }

  private void widgetDisposed(DisposeEvent e) {
    Utils.dispose(m_iconImage);
  }

  public User getUser() {
    return m_user;
  }

  private Label m_icon;
  private Label m_view;
  private Label m_name;
  
  // resources that need to be disposed
  private Image m_iconImage;

  private final User m_user;
}
