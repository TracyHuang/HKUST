package hk.ust.cse.TwitterClient.Views.User;

import hk.ust.cse.TwitterClient.Utils;
import hk.ust.cse.TwitterClient.Resources.Resources;
import hk.ust.cse.TwitterClient.Views.Basic.RowComposite;

import org.eclipse.swt.SWT;
import org.eclipse.swt.events.DisposeEvent;
import org.eclipse.swt.events.DisposeListener;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.layout.RowData;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;

import twitter4j.User;

public class ProfileView extends RowComposite {
  
  public ProfileView(Composite parentView, User user, int width, int height) {
    super(parentView, SWT.CENTER, SWT.VERTICAL, true, 20, 25, 40, 40, 2);
    
    m_user = user;
    
    initialize(width, height);
    
    // a dispose listener is necessary
    addDisposeListener(new DisposeListener() {
      public void widgetDisposed(DisposeEvent e) {
        ProfileView.this.widgetDisposed(e);
      }
    });
  }
  
  // initialize widgets within the profile composite
  private void initialize(int width, int height) {
    // set size
    setSize(width, height);
    
    // set background color
    if (m_user.getProfileBannerURL() != null) {
      Image oriImage = Utils.loadImageFromUrlAndScale(m_user.getProfileBannerURL(), width, height);
      if (oriImage != null) {
        m_bgImage = Utils.darkGradually(oriImage, (int) (height * 0.25));
        oriImage.dispose();
      }
    }
    else {
      m_bgImage = Utils.loadImageFromUrlAndScale(
          "https://si0.twimg.com/a/1356725833/t1/img/grey_header_web.png", width, height);
    }
    if (m_bgImage != null) {
      setBackgroundImage(m_bgImage);
    }
    setBackgroundMode(SWT.INHERIT_DEFAULT); // make all labels have transparent backgrounds
    
    // set profile icon's outer frame
    RowComposite iconFrame = new RowComposite(this, SWT.CENTER, SWT.HORIZONTAL, true, 4, 4, 4, 4, -1);
    iconFrame.setBackground(Resources.WHITE_COLOR);
    iconFrame.setLayoutData(new RowData(81, 81));

    // set profile icon
    m_icon = new Label(iconFrame, SWT.CENTER);
    if (m_user.getBiggerProfileImageURL() != null) {
      m_iconImage = Utils.loadImageFromUrlAndScale(m_user.getBiggerProfileImageURL(), 73, 73);
      if (m_iconImage != null) {
        m_icon.setImage(m_iconImage);
      }
    }
    m_icon.setLayoutData(new RowData(73, 73));

    // set name and verified icon's outer frame
    RowComposite nameFrame = new RowComposite(this, SWT.CENTER, SWT.HORIZONTAL, true, -1, -1, -1, -1, 5);
    
    // set name and verified icon
    m_name = new Label(nameFrame, SWT.CENTER);
    m_name.setFont(Resources.FONT18B);
    m_name.setForeground(Resources.WHITE_COLOR);
    m_name.setText(m_user.getName());
    if (m_user.isVerified()) {
      m_verified = new Label(nameFrame, SWT.CENTER);
      m_verified.setImage(Resources.VERIFIED_IMG);
    }
    
    // set screen name
    m_screenName = new Label(this, SWT.CENTER);
    m_screenName.setFont(Resources.FONT14);
    m_screenName.setForeground(Resources.WHITE_COLOR);
    m_screenName.setText("@" + m_user.getScreenName());
    
    // description under screen name
    m_description = new Label(this, SWT.WRAP | SWT.CENTER);
    m_description.setFont(Resources.FONT11);
    m_description.setForeground(Resources.WHITE_COLOR);
    m_description.setText(m_user.getDescription());
    m_description.setLayoutData(new RowData(
        getBounds().width - 80, m_user.getDescription().length() > 0 ? -1 : 0));

    // set Location web site together
    String location = m_user.getLocation() != null ? m_user.getLocation() : "";
    String webSite  = m_user.getURL() != null ? m_user.getURLEntity().getDisplayURL() : "";
    boolean shouldSplit = location.length() > 0 && webSite.length() > 0;
    m_locationWebSite = new Label(this, SWT.WRAP | SWT.CENTER);
    m_locationWebSite.setFont(Resources.FONT11);
    m_locationWebSite.setForeground(Resources.WHITE_COLOR);
    m_locationWebSite.setText(location + (shouldSplit ? " - " : "") + webSite);
    
    layout(); // trigger re-layout
    
//    // cut corner only after layout()
//    Utils.cutRoundCorner(m_iconFrame, true, true, true, true);
//    Utils.cutRoundCorner(m_iconImage, true, true, true, true);
  }
  
  private void widgetDisposed(DisposeEvent e) {
    // dispose loaded images
    Utils.dispose(m_bgImage);
    Utils.dispose(m_iconImage);
  }

  public User getUser() {
    return m_user;
  }

  private Label m_icon;
  private Label m_name;
  private Label m_verified;
  private Label m_screenName;
  private Label m_description;
  private Label m_locationWebSite;
  
  // resources that need to be disposed
  private Image m_bgImage;
  private Image m_iconImage;

  private final User m_user;
}
