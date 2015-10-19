package hk.ust.cse.TwitterClient.Views.User;

import hk.ust.cse.TwitterClient.Resources.Resources;
import hk.ust.cse.TwitterClient.Views.Basic.HoverClickableComposite;

import org.eclipse.swt.SWT;
import org.eclipse.swt.events.DisposeEvent;
import org.eclipse.swt.events.DisposeListener;
import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.events.MouseTrackListener;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.layout.RowData;
import org.eclipse.swt.layout.RowLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;

public class UserMenuItem extends HoverClickableComposite {
  
  public UserMenuItem(Composite parentView, String title, int width, int height, Font titleFont, Font clickedTitleFont) {
    super(parentView, Resources.MINI_PROFILE_COLOR, Resources.WHITE_COLOR, Resources.WHITE_COLOR);

    m_title            = title;
    m_titleFont        = titleFont;
    m_clickedTitleFont = clickedTitleFont;
    
    initialize(width, height);
    
    addMouseTrackListener(new MouseTrackListener() {
      @Override
      public void mouseHover(MouseEvent arg0) {
      }
      
      @Override
      public void mouseExit(MouseEvent arg0) {
        Rectangle rect = UserMenuItem.this.getClientArea();
        if (!isClicked() && !rect.contains(arg0.x, arg0.y)) {
          m_goIcon.setImage(Resources.GO_IMG);
          m_titleLabel.setForeground(Resources.LINK_COLOR);
        }
      }
      
      @Override
      public void mouseEnter(MouseEvent arg0) {
        if (!isClicked()) {
          m_goIcon.setImage(Resources.GO_CLICKED_IMG);
          m_titleLabel.setForeground(Resources.TEXT_COLOR);
        }
      }
    });
    
    // a dispose listener is necessary
    addDisposeListener(new DisposeListener() {
      public void widgetDisposed(DisposeEvent e) {
        UserMenuItem.this.widgetDisposed(e);
      }
    });
  }

  private void initialize(int width, int height) {
    // set size
    setSize(width, height);
    
    // set layout of the view
    RowLayout layout = new RowLayout(SWT.HORIZONTAL);
    layout.center       = true;
    layout.marginTop    = 0;
    layout.marginBottom = 0;
    layout.marginLeft   = 10;
    layout.marginRight  = 10;
    layout.spacing      = 0;
    setLayout(layout);
    
    setBackgroundMode(SWT.INHERIT_DEFAULT); // make all labels have transparent backgrounds

    // necessary to place content in the middle
    Composite alignMiddle = new Composite(this, 0);
    alignMiddle.setLayoutData(new RowData(0, height));
    
    // set title
    m_titleLabel = new Label(this, SWT.LEFT);
    m_titleLabel.setFont(m_titleFont);
    m_titleLabel.setForeground(Resources.LINK_COLOR);
    m_titleLabel.setText(m_title);
    m_titleLabel.setLayoutData(new RowData(getBounds().width - 29, -1));

    // set > icon
    m_goIcon = new Label(this, SWT.RIGHT);
    m_goIcon.setImage(Resources.GO_IMG);
    m_goIcon.setLayoutData(new RowData(9, 13));
    
    layout(); // trigger re-layout
    pack(); // force re-size
  }
  
  private void widgetDisposed(DisposeEvent e) {
  }
  
  public void setClicked() {
    super.setClicked();
    m_titleLabel.setFont(m_clickedTitleFont);
    m_titleLabel.setForeground(Resources.TEXT_COLOR);
    m_goIcon.setImage(Resources.GO_CLICKED_IMG);
  }
  
  public void setNotClicked() {
    super.setNotClicked();
    m_titleLabel.setFont(m_titleFont);
    m_titleLabel.setForeground(Resources.LINK_COLOR);
    m_goIcon.setImage(Resources.GO_IMG);
  }
  
  public String getTitle() {
    return m_title;
  }

  private final String m_title;
  private final Font   m_titleFont;
  private final Font   m_clickedTitleFont;
  
  private Label m_titleLabel;
  private Label m_goIcon;
}
