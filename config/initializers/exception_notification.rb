App::Application.config.middleware.use ExceptionNotifier,
                                       :email_prefix => "[ERROR]",
                                       :sender_address => '"Notifier" <notifier@footbllshirthq.com>',
                                       :exception_recipients => ['admin@footbllshirthq.com']