package Tab::ConcessionPurchase;
use base 'Tab::DBI';
Tab::ConcessionPurchase->table('concession_purchase');
Tab::ConcessionPurchase->columns(Essential => qw/id concession quantity school placed fulfilled timestamp/);
Tab::ConcessionPurchase->has_a(school => 'Tab::School');
Tab::ConcessionPurchase->has_a(concession => 'Tab::Concession');
__PACKAGE__->_register_datetimes( qw/timestamp placed/);
