package hk.ust.cse.TwitterClient.Views;

import hk.ust.cse.TwitterClient.Utils;
import hk.ust.cse.TwitterClient.Resources.Resources;
import hk.ust.cse.TwitterClient.Views.Basic.RowComposite;

import org.eclipse.swt.SWT;
import org.eclipse.swt.events.DisposeEvent;
import org.eclipse.swt.events.DisposeListener;
import org.eclipse.swt.events.FocusEvent;
import org.eclipse.swt.events.FocusListener;
import org.eclipse.swt.layout.RowData;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Text;

public class ControlBar extends RowComposite {
  public ControlBar(Composite parentView, int width, int height, int initLeftMargin, 
      String btnClkHandler, String enterHandler, Object handlerCallee) {
    super(parentView, SWT.CENTER, SWT.HORIZONTAL, false, 0, 0, initLeftMargin, 0, 40);
    
    m_btnClkHandler = btnClkHandler;
    m_enterHandler  = enterHandler;
    m_handlerCallee = handlerCallee;
    
    initialize(width, height, initLeftMargin);
    
    // a dispose listener is necessary
    addDisposeListener(new DisposeListener() {
      public void widgetDisposed(DisposeEvent e) {
        ControlBar.this.widgetDisposed(e);
      }
    });
  }
  
  private void initialize(int width, int height, int initLeftMargin) {
    // set size
    setSize(width, height);
    
    // set background color
    setBackground(Resources.CONTROL_BAR_COLOR);
    setBackgroundMode(SWT.INHERIT_DEFAULT); // make all labels have transparent backgrounds
    
    // set button frame
    RowComposite buttonFrame = new RowComposite(this, SWT.LEFT, SWT.HORIZONTAL, false, 10, 0, 0, 0, 40);
    buttonFrame.setBackground(Resources.CONTROL_BAR_COLOR);
    buttonFrame.setLayoutData(new RowData(-1, height));
    
    // set Home button
    m_home = new ControlBarItem(buttonFrame, "Home", Resources.HOME_IMG, Resources.HOME_HOVER_IMG);
    m_home.setLayoutData(new RowData(Resources.HOME_IMG.getBounds().width, 
                                   Resources.HOME_IMG.getBounds().height));
    Utils.addClickListener(m_home, m_btnClkHandler, m_handlerCallee);
    
    // set Me button
    m_me = new ControlBarItem(buttonFrame, "Me", Resources.ME_IMG, Resources.ME_HOVER_IMG);
    m_me.setLayoutData(new RowData(Resources.ME_IMG.getBounds().width, 
                                   Resources.ME_IMG.getBounds().height));
    Utils.addClickListener(m_me, m_btnClkHandler, m_handlerCallee);
    
    // set text box and goto people button frame
    RowComposite gotoFrame = new RowComposite(this, SWT.LEFT, SWT.HORIZONTAL, false, 7, 7, 0, 0, 10);
    gotoFrame.setBackground(Resources.CONTROL_BAR_COLOR);
    gotoFrame.setLayoutData(new RowData(250, height));
    
    final RowComposite textFrame = new RowComposite(gotoFrame, SWT.LEFT, SWT.HORIZONTAL, false, 3, 3, 0, 0, -1);
    textFrame.setBackground(Resources.SPLIT_COLOR);
    
    // set search text box
    m_people = new Text(textFrame, SWT.LEFT);
    m_people.setFont(Resources.FONT11);
    m_people.setBackground(Resources.SPLIT_COLOR);
    m_people.setForeground(Resources.TEXT_COLOR);
    m_people.setLayoutData(new RowData(200, height - 20));
    m_people.addFocusListener(new FocusListener() {
      @Override
      public void focusLost(FocusEvent arg0) {
        m_people.setBackground(Resources.SPLIT_COLOR);
        textFrame.setBackground(Resources.SPLIT_COLOR);
      }
      
      @Override
      public void focusGained(FocusEvent arg0) {
        m_people.setBackground(Resources.WHITE_COLOR);
        textFrame.setBackground(Resources.WHITE_COLOR);
      }
    });
    Utils.addEnterListener(m_people, m_enterHandler, m_handlerCallee);
    
    // set goto people button
    RowComposite gotoBtnFrame = new RowComposite(gotoFrame, SWT.LEFT, SWT.HORIZONTAL, false, 3, 0, 0, 0, -1);
    gotoBtnFrame.setBackground(Resources.CONTROL_BAR_COLOR);

    m_gotoPeople = new ControlBarItem(gotoBtnFrame, 
        "Go to people", Resources.PEOPLE_IMG, Resources.PEOPLE_HOVER_IMG);
    m_gotoPeople.setLayoutData(new RowData(Resources.PEOPLE_IMG.getBounds().width, 
                                           Resources.PEOPLE_IMG.getBounds().height));
    Utils.addClickListener(m_gotoPeople, m_btnClkHandler, m_handlerCallee);
    
    layout(); // trigger re-layout
  }
  
  private void widgetDisposed(DisposeEvent e) {
  }
  
  public String getGotoPeopleName() {
    return m_people.getText();
  }

  private ControlBarItem m_me;
  private ControlBarItem m_home;
  private Text           m_people;
  private ControlBarItem m_gotoPeople;
  
  private final String m_btnClkHandler;
  private final String m_enterHandler;
  private final Object m_handlerCallee;
}
