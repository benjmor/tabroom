/* jshint indent: 4 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('hotel', { 
		name: {
			type: DataTypes.STRING(63),
			allowNull: false,
			defaultValue: ''
		},
		fee_multiplier: { 
			type: DataTypes.FLOAT,
			allowNull: true
		}
	});
};


