package hk.ust.cse.TwitterClient.Views.Basic;

import hk.ust.cse.TwitterClient.Resources.Resources;

import org.eclipse.swt.SWT;
import org.eclipse.swt.events.DisposeEvent;
import org.eclipse.swt.events.DisposeListener;
import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.events.MouseTrackListener;
import org.eclipse.swt.widgets.Composite;

public class ClickableComposite extends Composite {
  
  public ClickableComposite(Composite parentView) {
    super(parentView, SWT.CENTER);
 
    addMouseTrackListener(new MouseTrackListener() {
      @Override
      public void mouseHover(MouseEvent arg0) {
      }
      
      @Override
      public void mouseExit(MouseEvent arg0) {
      }
      
      @Override
      public void mouseEnter(MouseEvent arg0) { 
        setCursor(Resources.HAND_CURSOR);
      }
    });
    
    // a dispose listener is necessary
    addDisposeListener(new DisposeListener() {
      public void widgetDisposed(DisposeEvent e) {
        ClickableComposite.this.widgetDisposed(e);
      }
    });
  }
  
  private void widgetDisposed(DisposeEvent e) {
  }
}
