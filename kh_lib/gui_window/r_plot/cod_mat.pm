package gui_window::r_plot::cod_mat;
use base qw(gui_window::r_plot);


sub option1_options{
	return [
		kh_msg->get('heat'), # 'ヒートマップ',
		kh_msg->get('fluc'), # 'バブルプロット',
	];
}

sub option1_name{
	return kh_msg->get('gui_window::r_plot::word_corresp->view'); # ' 表示：';
}

sub photo_pane_width{
	my $self = shift;
	return 640;
}

sub win_title{
	return kh_msg->get('win_title');
}

sub win_name{
	return 'w_cod_mat_plot';
}


sub base_name{
	return 'cod_mat';
}


1;