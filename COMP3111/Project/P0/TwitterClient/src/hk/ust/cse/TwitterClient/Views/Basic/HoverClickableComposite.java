package hk.ust.cse.TwitterClient.Views.Basic;


import org.eclipse.swt.events.DisposeEvent;
import org.eclipse.swt.events.DisposeListener;
import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.events.MouseTrackListener;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.widgets.Composite;

public class HoverClickableComposite extends ClickableComposite {
  
  public HoverClickableComposite(Composite parentView, Color origColor, Color hoverColor, Color clickedColor) {
    super(parentView);

    m_clicked      = false;    
    m_origColor    = origColor;
    m_hoverColor   = hoverColor;
    m_clickedColor = clickedColor;
    
    initialize();
    
    addMouseTrackListener(new MouseTrackListener() {
      @Override
      public void mouseHover(MouseEvent arg0) {
      }
      
      @Override
      public void mouseExit(MouseEvent arg0) {
        Rectangle rect = HoverClickableComposite.this.getClientArea();
        if (!m_clicked && !rect.contains(arg0.x, arg0.y)) {
          setBackground(m_origColor);
        }
      }
      
      @Override
      public void mouseEnter(MouseEvent arg0) { 
        if (!m_clicked) {
          setBackground(m_hoverColor);
        }
      }
    });
    
    // a dispose listener is necessary
    addDisposeListener(new DisposeListener() {
      public void widgetDisposed(DisposeEvent e) {
        HoverClickableComposite.this.widgetDisposed(e);
      }
    });
  }
  
  private void initialize() {
    setBackground(m_origColor);
  }
  
  private void widgetDisposed(DisposeEvent e) {
  }
  
  public void setClicked() {
    m_clicked = true;
    setBackground(m_clickedColor);
  }
  
  public void setNotClicked() {
    m_clicked = false;
    setBackground(m_hoverColor);
  }
  
  public boolean isClicked() {
    return m_clicked;
  }
  
  private boolean m_clicked;
  
  private final Color m_origColor;
  private final Color m_hoverColor;
  private final Color m_clickedColor;
}
