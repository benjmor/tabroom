package Tab::Entry;
use base 'Tab::DBI';
Tab::Entry->table('entry');
Tab::Entry->columns(Primary => qw/id/);
Tab::Entry->columns(Essential => qw/code name active dropped waitlist 
									unconfirmed dq tourn school event/);

Tab::Entry->columns(Others => qw/registered_by ada tba created_at timestamp/);

Tab::Entry->columns(TEMP => qw/panelid speaks side ballot othername schname regname 
								regcode region pullup bracketseed won lost schoolid categoryid eventid/);

Tab::Entry->has_a(school => 'Tab::School');
Tab::Entry->has_a(tourn => 'Tab::Tourn');
Tab::Entry->has_a(event => 'Tab::Event');

Tab::Entry->has_a(registered_by => 'Tab::Person');

Tab::Entry->has_many(strikes => 'Tab::Strike', 'entry');
Tab::Entry->has_many(settings => 'Tab::EntrySetting', 'entry');
Tab::Entry->has_many(ballots => 'Tab::Ballot', 'entry');
Tab::Entry->has_many(changes => 'Tab::ChangeLog', 'entry');
Tab::Entry->has_many(ratings => 'Tab::Rating', 'entry');
Tab::Entry->has_many(qualifiers => 'Tab::Qualifier', 'entry');
Tab::Entry->has_many(entry_students => 'Tab::EntryStudent', 'entry');
Tab::Entry->has_many(students => [Tab::EntryStudent => 'student']);

__PACKAGE__->_register_datetimes( qw/timestamp created_at/);

sub add_student { 

	my ($self, $student) = @_;

	my @existing = Tab::EntryStudent->search( 
		student => $student,
		entry   => $self->id
	);

	Tab::EntryStudent->create({ 
		student => $student, 
		entry => $self->id }) unless @existing;
	return;
}

sub rm_student { 

	my ($self, $student) = @_;

	my @existing = Tab::EntryStudent->search( 
		student => $student,
		entry   => $self->id 
	);

	foreach (@existing) { $_->delete; }
	return;
}


sub setting {

	my ($self, $tag, $value, $blob) = @_;

	$/ = "";			#Remove all trailing newlines
	chomp $blob;

	my $existing = Tab::EntrySetting->search(
		entry => $self->id,
		tag   => $tag
	)->first;

	if (defined $value) {
			
		if ($existing) {

			$existing->value($value);
			$existing->value_text($blob) if $value eq "text";
			$existing->value_date($blob) if $value eq "date";
			$existing->update;

			if ($value eq "delete" || $value eq "" || $value eq "0") { 
				$existing->delete;
			}

			return;

		} elsif ($value ne "delete" && $value && $value ne "0") {

			my $existing = Tab::EntrySetting->create({
				entry => $self->id,
				tag    => $tag,
				value  => $value,
			});

			if ($value eq "text") { 
				$existing->value_text($blob);
			}

			if ($value eq "date") { 
				$existing->value_date($blob);
			}

			$existing->update;

		}

	} else {

		return unless $existing;
		return $existing->value_text if $existing->value eq "text";
		return $existing->value_date if $existing->value eq "date";
		return $existing->value;

	}

}



sub all_settings { 

	my $self = shift;

	my %all_settings;

	my $dbh = Tab::DBI->db_Main();

    my $sth = $dbh->prepare("
		select setting.tag, setting.value, setting.value_date, setting.value_text
		from entry_setting setting
		where setting.entry = ? 
        order by setting.tag
    ");
    
    $sth->execute($self->id);
    
    while( my ($tag, $value, $value_date, $value_text)  = $sth->fetchrow_array() ) { 

		if ($value eq "date") { 

			my $dt = eval { 
				return DateTime::Format::MySQL->parse_datetime($value_date); 
			};

			$all_settings{$tag} = $dt if $dt;

		} elsif ($value eq "text") { 

			$all_settings{$tag} = $value_text;

		} else { 

			$all_settings{$tag} = $value;

		}

	}

	return %all_settings;

}

