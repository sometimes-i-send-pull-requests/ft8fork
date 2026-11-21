#include "SplashScreen.hpp"

#include <QPixmap>
#include <QVBoxLayout>
#include <QCheckBox>
#include <QCoreApplication>
#include <QApplication>
#include <QPainter>

#include "revision_utils.hpp"
#include "pimpl_impl.hpp"

#include "moc_SplashScreen.cpp"

class SplashScreen::impl
{
public:
  impl ()
    : checkbox_ {"Do not show this again"}
  {
    main_layout_.addStretch ();
    main_layout_.addWidget (&checkbox_, 0, Qt::AlignRight);
  }

  QVBoxLayout main_layout_;
  QCheckBox checkbox_;
};

namespace
{
  // Plain window-coloured background for the text drawn by QSplashScreen.
  QPixmap splash_background (QSize const& size)
  {
    QPixmap background {size};
    auto const& palette = QApplication::palette ();
    background.fill (palette.color (QPalette::Window));
    QPainter painter {&background};
    painter.setPen (palette.color (QPalette::Mid));
    painter.drawRect (background.rect ().adjusted (0, 0, -1, -1));
    return background;
  }
}

SplashScreen::SplashScreen ()
  : QSplashScreen {splash_background ({480, 180}), Qt::WindowStaysOnTopHint}
{
  setLayout (&m_->main_layout_);
  showMessage ("<h2>" + QString {"FT8Fork v" +
        QCoreApplication::applicationVersion() + " " +
        revision ()}.simplified () + "</h2>"
    "Send issue reports to this project's issue tracker, and be sure to save<br />"
    ".wav files where appropriate.  This is an unofficial fork of WSJT-X<br />"
    "and is not supported by the WSJT Development Team.<br /><br />"
    "<b>Open the Help menu and select Release Notes for more details.</b><br />"
    "<img src=\":/gpl-v3-logo.svg\" height=\"80\" />", Qt::AlignCenter);
  connect (&m_->checkbox_, &QCheckBox::stateChanged, [this] (int s) {
      if (Qt::Checked == s) Q_EMIT disabled ();
    });
}

SplashScreen::~SplashScreen ()
{
}
