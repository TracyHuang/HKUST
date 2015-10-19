package hk.ust.cse.TwitterClient.Views;

import hk.ust.cse.TwitterClient.Resources.Resources;
import hk.ust.cse.TwitterClient.Views.Basic.ClickableComposite;

import org.eclipse.swt.SWT;
import org.eclipse.swt.events.DisposeEvent;
import org.eclipse.swt.events.DisposeListener;
import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.events.MouseTrackListener;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.widgets.Composite;

public class ControlBarItem extends ClickableComposite {
  
  public ControlBarItem(Composite parentView, String title, Image image, Image hoverImage) {
    super(parentView);

    m_title      = title;
    m_image      = image;
    m_hoverImage = hoverImage;
    
    initialize();
    
    addMouseTrackListener(new MouseTrackListener() {
      @Override
      public void mouseHover(MouseEvent arg0) {
      }
      
      @Override
      public void mouseExit(MouseEvent arg0) {
        Rectangle rect = ControlBarItem.this.getClientArea();
        if (!rect.contains(arg0.x, arg0.y)) {
          setBackgroundImage(m_image);
        }
      }
      
      @Override
      public void mouseEnter(MouseEvent arg0) { 
        setBackgroundImage(m_hoverImage);
      }
    });
    
    // a dispose listener is necessary
    addDisposeListener(new DisposeListener() {
      public void widgetDisposed(DisposeEvent e) {
        ControlBarItem.this.widgetDisposed(e);
      }
    });
  }

  private void initialize() {
    // set size
    setSize(m_image.getBounds().width, m_image.getBounds().height);

    // set background color
    setBackground(Resources.CONTROL_BAR_COLOR);
    setBackgroundMode(SWT.INHERIT_DEFAULT); // make all labels have transparent backgrounds

    setBackgroundImage(m_image);
    setToolTipText(m_title);

    layout(); // trigger re-layout
  }
  
  private void widgetDisposed(DisposeEvent e) {
  }
  
  public String getTitle() {
    return m_title;
  }

  private final String m_title;
  private final Image  m_image;
  private final Image  m_hoverImage;
}
