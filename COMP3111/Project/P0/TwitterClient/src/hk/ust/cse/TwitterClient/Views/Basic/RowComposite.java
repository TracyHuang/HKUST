package hk.ust.cse.TwitterClient.Views.Basic;

import org.eclipse.swt.layout.RowData;
import org.eclipse.swt.layout.RowLayout;
import org.eclipse.swt.widgets.Composite;

public class RowComposite extends Composite {

  public RowComposite(Composite parent, int style, int layoutStyle, boolean center, 
      int marginTop, int marginBottom, int marginLeft, int marginRight, int spacing) {
    super(parent, style);
    
    m_layout = new RowLayout(layoutStyle);
    m_layout.center       = center;
    m_layout.marginTop    = marginTop >= 0 ? marginTop : m_layout.marginTop;
    m_layout.marginBottom = marginBottom >= 0 ? marginBottom : m_layout.marginBottom;
    m_layout.marginLeft   = marginLeft >= 0 ? marginLeft : m_layout.marginLeft;
    m_layout.marginRight  = marginRight >= 0 ? marginRight : m_layout.marginRight;
    m_layout.spacing      = spacing >= 0 ? spacing :m_layout.spacing;
    setLayout(m_layout);
  }
  
  // use together with the center parameter
  public void setAlignMiddle(int height) {
    Composite alignMiddle = new Composite(this, 0);
    alignMiddle.setLayoutData(new RowData(0, height));
  }
  
  public int getWidth() {
    return getBounds().width;
  }
  
  public int getHeight() {
    return getBounds().height;
  }
  
  private final RowLayout m_layout;

}
