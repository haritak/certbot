# https://github.com/mperham/sidekiq/wiki/Advanced-Options#capsules
# Starting in 7.0, Sidekiq allows you to declare Capsules which can provide single-threaded or serial execution of a queue.
Sidekiq.configure_server do |config|
  config.capsule("unsafe") do |cap|
    cap.concurrency = 1
    cap.queues = %w[odt2pdf]
  end
end
